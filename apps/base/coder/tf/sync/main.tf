data "tencentcloud_teo_origin_acl" "coder" {
  zone_id = var.edgeone_zone_id
}

locals {
  current_origin_ipv6_cidrs = try(
    data.tencentcloud_teo_origin_acl.coder.origin_acl_info[0].current_origin_acl[0].entire_addresses[0].ipv6,
    [],
  )
  next_origin_ipv6_cidrs = try(
    data.tencentcloud_teo_origin_acl.coder.origin_acl_info[0].next_origin_acl[0].entire_addresses[0].ipv6,
    [],
  )
  edgeone_origin_ipv6_cidrs = sort(distinct(concat(
    local.current_origin_ipv6_cidrs,
    local.next_origin_ipv6_cidrs,
  )))
}

resource "kubernetes_manifest" "coder_origin_policy" {
  count = length(local.edgeone_origin_ipv6_cidrs) > 0 ? 1 : 0

  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "coder-edgeone-origin-allow"
      namespace = var.gateway_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "tofu-controller"
        "app.kubernetes.io/part-of"    = "coder"
      }
    }
    spec = {
      endpointSelector = {
        matchLabels = {
          "gateway.networking.k8s.io/gateway-name" = "coder-gateway"
        }
      }
      ingress = [
        {
          fromCIDRSet = [
            for cidr in local.edgeone_origin_ipv6_cidrs : {
              cidr = cidr
            }
          ]
          toPorts = [
            {
              ports = [
                {
                  port     = "443"
                  protocol = "TCP"
                },
              ]
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "coder_wildcard_dns" {
  manifest = {
    apiVersion = "externaldns.k8s.io/v1alpha1"
    kind       = "DNSEndpoint"
    metadata = {
      name      = "coder-edgeone"
      namespace = var.gateway_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "tofu-controller"
        "app.kubernetes.io/part-of"    = "coder"
      }
    }
    spec = {
      endpoints = [
        {
          dnsName    = var.acceleration_domain
          recordType = "CNAME"
          targets    = [var.edgeone_cname]
          providerSpecific = [
            {
              name  = "external-dns.alpha.kubernetes.io/cloudflare-proxied"
              value = "false"
            },
          ]
        },
      ]
    }
  }

}
