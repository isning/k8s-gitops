# Flux Operator bootstrap

Optional Terraform bootstrap for kubevirt-lab-1. Kubernetes nodes remain managed by isning/nix-config.

Use the shared Cilium values and the pinned Flux Operator bootstrap module. Copy terraform.tfvars.example, set the kubeconfig/context and provide TF_VAR_sops_age_key through the environment. Run terraform init, fmt -check, validate and review the plan before applying.
