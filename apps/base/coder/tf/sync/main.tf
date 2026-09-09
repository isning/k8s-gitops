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
