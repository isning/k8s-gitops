output "edgeone_cname" {
  description = "EdgeOne CNAME published by ExternalDNS"
  value       = tencentcloud_teo_acceleration_domain.coder.cname
}

output "gateway_ipv6" {
  description = "Current dynamic Coder Gateway origin address"
  value       = local.gateway_ipv6
}
