variable "kubeconfig" {
  description = "Path to the kubeconfig for the target cluster."
  type        = string
  nullable    = false
}

variable "kube_context" {
  description = "Optional kubeconfig context; null uses the current context."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Cluster directory under clusters/ and infra/pre-controllers/overlays/."
  type        = string
  default     = "kubevirt-lab-1"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.cluster_name))
    error_message = "cluster_name must be a directory name containing lowercase letters, digits and hyphens."
  }
}

variable "bootstrap_revision" {
  description = "Positive integer run revision; increment to rerun the bootstrap job. The Git branch comes from clusters/<cluster>/flux.yaml."
  type        = number
  default     = 1
  nullable    = false

  validation {
    condition     = var.bootstrap_revision >= 1 && floor(var.bootstrap_revision) == var.bootstrap_revision
    error_message = "bootstrap_revision must be a positive integer."
  }
}

variable "sops_age_key" {
  description = "SOPS age private key contents, supplied via TF_VAR_sops_age_key."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = strcontains(var.sops_age_key, "AGE-SECRET-KEY-")
    error_message = "sops_age_key must contain an age private key."
  }
}
