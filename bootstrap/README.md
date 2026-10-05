# Flux Operator bootstrap

This optional entrypoint installs Cilium, Flux Operator and the cluster's
FluxInstance on a new cluster. Kubernetes/node provisioning remains in
[isning/nix-config](https://github.com/isning/nix-config/tree/main/hosts/k8s).
Existing clusters can continue using their current bootstrap method.

## Shared configuration

Bootstrap and Flux read the same Cilium values from
`infra/pre-controllers/overlays/<cluster>/cilium/values.yaml`. Bootstrap reads
the Cilium and Flux Operator chart digests from their existing OCIRepository
manifests, so there is no second chart version to update here. The FluxInstance
in `clusters/<cluster>/flux.yaml` selects the Git repository, branch, cluster
path and Flux controller versions.

The bootstrap Job uses host networking, tolerates not-ready/control-plane nodes
and takes its API host and port from the first URL in Cilium's
`k8s.apiServerURLs`. That address must be reachable from every node where the
Job can run before Cilium is installed. The homelab keeps its existing L2
advertisements, IPv6 pool reconciliation and single-node Cilium settings.

## Prepare and validate

Use Terraform 1.11+ or an OpenTofu version that supports the module's Terraform
1.11 constraints and write-only Kubernetes Secret arguments. The module is
pinned to 0.7.0. Both providers use the same kubeconfig and optional context.

Run from the repository root:

```bash
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
# Edit kubeconfig, kube_context and cluster_name for the target cluster.
terraform -chdir=bootstrap init
terraform -chdir=bootstrap fmt -check
terraform -chdir=bootstrap validate
```

For another cluster, first prepare `clusters/<cluster>/flux.yaml` and the matching
Cilium overlay/values, including API address and routing CIDRs. Confirm the target
context before planning.

## Plan, apply and verify

Use the age private key that decrypts this repository's SOPS resources:

```bash
export TF_VAR_sops_age_key="$(cat ./k8s-gitops.agekey)"
terraform -chdir=bootstrap plan
# After reviewing the plan and target cluster:
terraform -chdir=bootstrap apply
unset TF_VAR_sops_age_key
```

Local tfvars, state and saved plans are ignored by Git. Keep the key out of tfvars,
command-line arguments and committed files. Protect local state and any saved
plans as private bootstrap artifacts.

```bash
kubectl --kubeconfig /path/to/kubeconfig --context kubevirt-lab-1 get pods -n kube-system
kubectl --kubeconfig /path/to/kubeconfig --context kubevirt-lab-1 get fluxinstance -n flux-system
flux --kubeconfig /path/to/kubeconfig --context kubevirt-lab-1 get sources git -A
flux --kubeconfig /path/to/kubeconfig --context kubevirt-lab-1 get kustomizations -A
```

Rerunning the same configuration is supported. `bootstrap_revision` is a positive
integer run counter, not a Git branch; increment it to rerun the bootstrap Job.
Prerequisites and the FluxInstance use create-if-missing semantics and hand off
to Flux; the SOPS Secret remains managed by the bootstrap module. Continue with
the root README's staged reconciliation and manual post-bootstrap steps.

For air-gapped installs, stage the pinned bootstrap Job image
`ghcr.io/controlplaneio-fluxcd/flux-operator-bootstrap:0.7.0` and the Cilium,
Flux Operator and Flux controller images separately. The bootstrap Job is outside
the Flux manifest tree and is not discovered by the current image-lock generator.

Module reference:
[flux-operator-bootstrap v0.7.0](https://github.com/controlplaneio-fluxcd/terraform-kubernetes-flux-operator-bootstrap/tree/v0.7.0).
