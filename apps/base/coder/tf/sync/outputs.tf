output "edgeone_origin_ipv6_cidrs" {
  description = "Current and pending EdgeOne IPv6 origin-pull CIDRs, when advertised by the site plan"
  value       = local.edgeone_origin_ipv6_cidrs
}

output "cilium_origin_whitelist_active" {
  description = "Whether EdgeOne returned IPv6 origin ranges and the Cilium whitelist is active"
  value       = length(local.edgeone_origin_ipv6_cidrs) > 0
}
