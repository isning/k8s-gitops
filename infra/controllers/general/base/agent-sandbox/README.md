# Agent Sandbox

Deploy [Kubernetes SIGs Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox)
core and extensions into `kubevirt-lab-1` through Flux.

## Deployment plan

1. `infra-namespaces` creates `agent-sandbox-system` for the controller and
   `agent-sandbox` for workloads. Both enforce the Kubernetes v1.36 restricted Pod
   Security Standard. Namespace pruning stays disabled.
2. `infra-controllers-general` creates a pinned OCIRepository and a HelmRelease
   using our CI-published package of the official upstream chart. Helm installs the
   four CRDs, controller RBAC, metrics Service, and one controller replica with
   extensions    enabled. Chart values set resource limits and a restricted security context;
   the chart supplies health probes.
3. `infra-configs`, which depends on healthy controllers, installs the workload
   ServiceAccount, DNS-only NetworkPolicies, ResourceQuota, and `restricted-shell`
   SandboxTemplate. No Sandbox, Claim, or WarmPool is created during initial rollout.
4. Provision and verify gVisor on the nodes in the separate `isning/nix-config`
   repository. Then add a small warm pool and a smoke-test claim through GitOps.
5. After the smoke test passes, choose an actual agent runtime image and explicitly
   allow its required network destinations. Add persistence or a router only when a
   consumer needs them.

The existing namespace/controller/config dependency chain owns these resources;
there is no additional cluster bootstrap step. Submit the changes through a PR;
Flux applies them after the PR is reviewed and merged. Do not apply these manifests
manually or push directly to `main`.

## Pinned OCI chart and CRD lifecycle

The official chart lives in the upstream repository's `helm/` directory and is
not published to an official remote chart registry. Our
[publication workflow](../../../../../.github/workflows/publish-agent-sandbox-chart.yaml)
packages that chart into
`oci://ghcr.io/isning/k8s-gitops/charts/agent-sandbox`.
Flux consumes this package through OCIRepository + HelmRelease. The cluster does
not fetch the upstream Git repository.

[The publication config](../../../../../.github/agent-sandbox-chart.json) pins
upstream release `v1.0.5`, commit
`82d410efd5a279e887cdcf8c01e742a345fef63d`, and our package version
`1.0.5-repack.1`. This package version belongs to our distribution; the upstream
Chart.yaml version is `0.1.1`. Only chart version and appVersion metadata change;
templates and CRDs come from the pinned upstream checkout. Archive timestamps and
ownership are normalized so repeated builds produce identical package bytes.
The controller uses the matching upstream `v1.0.5` image with digest
`sha256:28a9cbdbfd6ac0a4e5c7e9261ace1aa30ee2da681cb640dccdfed98e8dd9d98b`.
Extensions are enabled. The official chart does not deploy a router.

The publication workflow lints and renders packages on PRs. Pushes that change the
publication config, script, or workflow publish using GitHub's built-in token;
manual workflow dispatch supports retries after the workflow reaches `main`.
Publishing on feature-branch pushes makes the package available before deployment
CI and Flux need it. Existing tags are verified and never overwritten; use a new
package version if content changes. Publication pulls the package back and compares
it byte-for-byte with the local build. The upload artifact contains the package
and rendered manifests; Helm's log reports the OCI digest.

The initial package has been verified by downloading both its OCI manifest and
chart blob anonymously and comparing the chart bytes with the local build. Its
manifest digest is pinned in `helm-oci-repo.yaml`:
`sha256:6a86bce200e67256bf3f078643ed9cb83da2ec399456478914f59130a342d860`.
For a new registry path, verify anonymous pull before deployment; if the package
is private, change its visibility to public in GitHub package settings. Record
the newly published OCI manifest digest in the source manifest before merging.

Local package preparation (requires the pinned upstream checkout):

```bash
nix run .#agent-sandbox-chart -- prepare \
  --source .local/agent-sandbox/helm --output .cache/agent-sandbox/publish
```

The chart does not create a Namespace; `infra-namespaces` owns both namespaces.
The HelmRelease installs CRDs with `Create` and upgrades them with `CreateReplace`;
Flux updates chart CRDs without a manual `kubectl apply`. CRDs in the chart's
`crds/` directory are retained on uninstall and are not owned by the surrounding
Kustomization's prune inventory. Deleting a CRD would cascade into user resources,
so CRD retirement remains a separate review. Keep the controller running until
claims, pools, and sandboxes have been retired and their finalizers have completed.

For upgrades, update the publication config with the reviewed upstream commit and
a new package version. Publish it, then update the OCI chart version and digest
together with the matching controller image tag and digest. Review the rendered
manifest diff, chart changes, and upstream release notes before merging.
The image lock is maintained by the repository's existing update workflow; do not
introduce an unpinned upstream URL or regenerate unrelated locks for an initial rollout.
The template declares `image-lock/extra-images` because the current lock generator
does not inspect the `SandboxTemplate` Pod spec.

## Runtime prerequisite

Inspection on 2026-10-09 found a single NixOS k3s node (`whitefox`, Kubernetes
v1.36.4) and no gVisor or Kata RuntimeClass. Agent Sandbox orchestrates Pods; the
controller installation does not install a container isolation runtime.

Configure `runsc` and the matching containerd handler on eligible nodes in
`isning/nix-config`, then manage a `gvisor` RuntimeClass with appropriate scheduling
constraints. A RuntimeClass alone does not install its handler. Verify that a Pod
using it actually starts on each eligible node. Do not remove `runtimeClassName`
from the template to bypass this prerequisite. Other clusters must update the
namespace Pod Security version and runtime configuration to match their nodes.

## Initial workload policy

The `restricted-shell` template is a small BusyBox shell for infrastructure testing,
not a Python/HTTP agent runtime. It uses gVisor, UID/GID 1000, no service account
token, no added capabilities, a read-only root filesystem, and bounded temporary
workspace volumes. Workspace data is ephemeral. The namespace budget permits up
to four Pods, with 4 CPU and 4 GiB aggregate limits; PVC creation is disabled.

Network policy denies ingress and egress except DNS to CoreDNS in `kube-system`.
Sandboxes cannot fetch packages or contact model APIs until explicit policies are
added. Template network policy management is `Unmanaged` so the controller does not
add broader default egress permissions. These namespace policies apply to all Pods;
Pod Security enforces Pod restrictions at admission. Restrict who can create or
modify workloads, templates, and policies in this namespace. This initial setup
does not implement a tenant access model or enforce gVisor on arbitrary raw Pods.

## Verification

After merging the PR, inspect the Flux stages and controller:

```bash
flux get ks -n flux-system
flux get sources oci -n agent-sandbox-system
flux get helmreleases -n agent-sandbox-system
kubectl get crd sandboxes.agents.x-k8s.io \
  sandboxclaims.extensions.agents.x-k8s.io \
  sandboxtemplates.extensions.agents.x-k8s.io \
  sandboxwarmpools.extensions.agents.x-k8s.io
kubectl rollout status deployment/agent-sandbox-controller \
  -n agent-sandbox-system --timeout=120s
kubectl get sandboxtemplates,networkpolicies,resourcequotas -n agent-sandbox
kubectl get runtimeclass gvisor
```

Only after the runtime prerequisite passes, add these resources under
`infra/configs/base/agent-sandbox/` and reference them in its Kustomization through
a separate PR:

```yaml
apiVersion: extensions.agents.x-k8s.io/v1beta1
kind: SandboxWarmPool
metadata:
  name: restricted-shell
spec:
  replicas: 1
  sandboxTemplateRef:
    name: restricted-shell
---
apiVersion: extensions.agents.x-k8s.io/v1beta1
kind: SandboxClaim
metadata:
  name: smoke-test
spec:
  warmPoolRef:
    name: restricted-shell
```

Claims in v1.0.5 require a `warmPoolRef`; they cannot reference templates directly.
Both resources must be in `agent-sandbox`. Allocating one claim can temporarily use
two Pods while the warm pool replenishes, which fits the initial quota.

Check claim readiness and inspect its allocated Sandbox and Pod. Confirm that the
Pod uses `gvisor`, runs as non-root, has no mounted Kubernetes token, can write to
`/workspace`, and cannot connect to another Pod, the API server, or the internet.
Test DNS resolution separately. Retire the smoke-test claim and warm pool through
a reviewed GitOps change after testing; claims do not expire automatically unless
`spec.lifecycle.shutdownTime` is explicitly set.
