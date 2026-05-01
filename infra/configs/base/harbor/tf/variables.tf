variable "harbor_url" {
  description = "Harbor base URL"
  type        = string
  default     = "https://harbor.isning.moe"
}

variable "harbor_username" {
  description = "Harbor admin username"
  type        = string
  default     = "admin"
}

variable "harbor_password" {
  description = "Harbor admin init password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_access_id" {
  type    = string
  default = ""
}

variable "dockerhub_access_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "ghcr_access_id" {
  type    = string
  default = ""
}

variable "ghcr_access_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "quay_access_id" {
  type    = string
  default = ""
}

variable "quay_access_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "gcr_access_id" {
  type    = string
  default = ""
}

variable "gcr_access_secret" {
  type      = string
  sensitive = true
  default   = ""
}
