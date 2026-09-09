provider "kubernetes" {
  host                   = "https://kubernetes.default.svc"
  token                  = try(file("/var/run/secrets/kubernetes.io/serviceaccount/token"), null)
  cluster_ca_certificate = try(file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"), null)
}
