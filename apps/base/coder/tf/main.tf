data "kubernetes_service_v1" "coder_gateway" {
  metadata {
    name      = var.gateway_service_name
    namespace = var.gateway_namespace
  }
}

locals {
  gateway_addresses = try(
    data.kubernetes_service_v1.coder_gateway.status[0].load_balancer[0].ingress,
    [],
  )
  gateway_ipv6_addresses = [
    for ingress in local.gateway_addresses : ingress.ip
    if ingress.ip != null && can(regex(":", ingress.ip))
  ]
  gateway_ipv6 = one(local.gateway_ipv6_addresses)
}

resource "tencentcloud_teo_acceleration_domain" "coder" {
  zone_id     = var.edgeone_zone_id
  domain_name = var.acceleration_domain

  origin_info {
    origin      = local.gateway_ipv6
    origin_type = "IP_DOMAIN"
  }

  status            = "online"
  origin_protocol   = "HTTPS"
  https_origin_port = 443
  ipv6_status       = "on"

  lifecycle {
    precondition {
      condition     = length(local.gateway_ipv6_addresses) == 1
      error_message = "coder-gateway-istio must expose exactly one IPv6 LoadBalancer address."
    }
  }
}

resource "tencentcloud_teo_certificate_config" "coder" {
  zone_id = var.edgeone_zone_id
  host    = tencentcloud_teo_acceleration_domain.coder.domain_name
  mode    = "eofreecert"
}

resource "tencentcloud_teo_origin_acl" "coder" {
  zone_id = var.edgeone_zone_id
  l7_hosts = [
    tencentcloud_teo_acceleration_domain.coder.domain_name,
  ]
}
