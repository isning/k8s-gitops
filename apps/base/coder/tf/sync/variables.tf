variable "edgeone_cname" {
  description = "CNAME allocated to the EdgeOne acceleration domain"
  type        = string
}

variable "acceleration_domain" {
  description = "Wildcard Coder workspace acceleration domain"
  type        = string
  default     = "*.coder.isning.moe"
}

variable "gateway_namespace" {
  description = "Namespace of the dedicated Coder Gateway"
  type        = string
  default     = "prod"
}
