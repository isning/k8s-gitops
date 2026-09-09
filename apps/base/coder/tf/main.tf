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

# Updating an IP_DOMAIN acceleration domain replays the API's computed "$host"
# value as a custom HostHeader, which ModifyAccelerationDomain rejects. Keep
# the domain's origin reference stable and rotate IPv6 addresses in this group.
resource "tencentcloud_teo_origin_group" "coder" {
  zone_id = var.edgeone_zone_id
  name    = "coder-gateway"
  type    = "GENERAL"

  records {
    record    = local.gateway_ipv6
    record_id = var.edgeone_origin_record_id
    type      = "IP_DOMAIN"
    weight    = 100
  }

  lifecycle {
    precondition {
      condition     = length(local.gateway_ipv6_addresses) == 1
      error_message = "coder-gateway-istio must expose exactly one IPv6 LoadBalancer address."
    }
  }
}

# The initial controller run may have created the EdgeOne domain before its
# interrupted apply persisted state. Keeping this import block makes recovery
# declarative and is a no-op once the resource is tracked.
import {
  to = tencentcloud_teo_acceleration_domain.coder
  id = "${var.edgeone_zone_id}#${var.acceleration_domain}"
}

resource "tencentcloud_teo_acceleration_domain" "coder" {
  zone_id     = var.edgeone_zone_id
  domain_name = var.acceleration_domain

  origin_info {
    origin      = tencentcloud_teo_origin_group.coder.origin_group_id
    origin_type = "ORIGIN_GROUP"
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
