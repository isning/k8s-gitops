output "edgeone_origin_ipv6_cidrs" {
  description = "Current and pending EdgeOne IPv6 origin-pull CIDRs"
  value       = local.edgeone_origin_ipv6_cidrs
}

output "origin_protection_ready" {
  description = "Whether the EdgeOne allow policy and public DNS may be created"
  value       = local.origin_protection_ready
}
