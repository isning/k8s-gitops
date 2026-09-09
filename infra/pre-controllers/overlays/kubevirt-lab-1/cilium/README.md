# Dynamic public IPv6 pool

Flux owns the CronJob, script, RBAC and fixed parameters. The CronJob exclusively
owns `default-public-ipv6-pool`; there is no public CIDR or bootstrap pool manifest
in Git. The private IPv4 pool remains fully managed by Flux.

Every five minutes, a short-lived non-root host-network Pod on `whitefox`:

1. asks the kernel which IPv6 source it would use for `IPV6_ROUTE_TARGET` (a UDP
   route lookup without sending a packet or contacting that target);
2. verifies that source is global, preferred, non-tentative and belongs to the
   configured uplink `ovsbr1` with a `/64` prefix;
3. creates or updates `<current-/64>:caf0::/112`, with `allowFirstLastIPs: No`,
   no service selector and allocation enabled;
4. waits for all IPv6 LoadBalancer Services to have addresses in that exact pool;
5. requests `prod/coder-edgeone-control` reconciliation once per new CIDR.

This does not depend on kubelet refreshing Node `InternalIP`. It reads the host
network namespace directly, without privileged mode, host filesystem mounts or
NET_ADMIN. Temporary SLAAC addresses are acceptable: only their `/64` matters.
No route, an unsuitable source or an unexpected interface/prefix aborts before
pool mutation. The existing pool is preserved. Multiple uplinks or multiple
public pools require an explicit design change; do not schedule this job across
multiple nodes. The upstream router must still route the selected `/64` to this
host/network; this job cannot repair an ISP or router routing failure.

ExternalDNS observes Service status for ordinary public records. The Coder
wildcard remains an EdgeOne CNAME; Tofu updates its origin group directly.
The last-notified CIDR is persisted only after the Tofu reconciliation request
succeeds; Tofu owns retries and the eventual API result. Failed Jobs retry, and
the next scheduled Job resumes from actual pool/Service state. A VMRule alerts
if the CronJob has no recent successful run. There is no permanent Pod.

## Safe handoff for an existing cluster

Before deploying the commit that removes the old public pool manifest, mark the
existing pool for retention and explicit adoption. For this repository use only
the `home` context, after verifying node `whitefox`:

```sh
kubectl --context home annotate ciliumloadbalancerippool default-public-ipv6-pool \
  kustomize.toolkit.fluxcd.io/prune=disabled \
  networking.isning.moe/managed-by=ipv6-pool-reconciler --overwrite
```

Verify both annotations before reconciling Flux. Retention must be present on
the live object, not merely in Git's old `IfNotPresent` manifest. This is a
one-time migration, not a permanent manual dependency. The task refuses to
adopt an existing unmarked pool. New clusters create a marked pool automatically.
The existing pool UID and Service addresses must remain unchanged during handoff.
Once handed off, the task removes the obsolete Flux tracking labels.

RBAC permits reading Services, getting/patching only the named public pool, and
patching only `prod/coder-edgeone-control`. Kubernetes cannot restrict `create`
by `resourceNames`, so pool creation is necessarily kind-scoped. No delete,
Secret access, Node access or cluster-wide Terraform mutation is granted.

## Verification

```sh
python3 -m unittest discover -s infra/pre-controllers/overlays/kubevirt-lab-1/cilium -p 'test_*.py'
```

The deployed script supports `--stage detect` (host-only inspection), `--check`
(read-only pool plan), `--stage pool` (pool only) and the default `--stage all`.
Run detection/checks in a host-network Pod on the configured node, not on a laptop.
Verify CronJob completion, the pool CIDR, all IPv6 Service addresses, Tofu Ready
conditions and external HTTPS separately. Do not renumber the production uplink
merely to test a prefix rotation; use mocked old/new kernel inputs for that case.
