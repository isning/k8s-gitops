provider "helm" {
  kubernetes = {
    config_path    = pathexpand(var.kubeconfig)
    config_context = var.kube_context
  }
}

provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig)
  config_context = var.kube_context
}

locals {
  cilium_values_path = "${path.module}/../infra/pre-controllers/overlays/${var.cluster_name}/cilium/values.yaml"
  cilium_values      = yamldecode(file(local.cilium_values_path))
  cilium_chart       = yamldecode(file("${path.module}/../infra/pre-controllers/base/cilium/helm-oci-repo.yaml")).spec
  operator_chart     = yamldecode(file("${path.module}/../infra/pre-controllers/base/flux/helm-oci-repo.yaml")).spec
  # Host-network jobs must reach the node API directly before the CNI exists.
  api_server = regex("^https://([^/]+):([0-9]+)$", split(" ", trimspace(local.cilium_values.k8s.apiServerURLs))[0])
}

module "flux_operator_bootstrap" {
  source  = "controlplaneio-fluxcd/flux-operator-bootstrap/kubernetes"
  version = "0.7.0"

  revision = var.bootstrap_revision

  job = {
    host_network = true
    tolerations = [
      {
        key      = "node.kubernetes.io/not-ready"
        operator = "Exists"
        effect   = "NoSchedule"
      },
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
      }
    ]
    env = {
      KUBERNETES_SERVICE_HOST = trim(local.api_server[0], "[]")
      KUBERNETES_SERVICE_PORT = local.api_server[1]
    }
  }

  gitops_resources = {
    instance_yaml = file("${path.module}/../clusters/${var.cluster_name}/flux.yaml")
    prerequisites = {
      charts = [{
        name        = "cilium"
        repository  = "${local.cilium_chart.url}@${local.cilium_chart.ref.digest}"
        namespace   = "kube-system"
        values_yaml = file(local.cilium_values_path)
        flux_adoption_check = {
          resource  = "helmreleases"
          api_group = "helm.toolkit.fluxcd.io"
          name      = "cilium"
          namespace = "kube-system"
        }
      }]
    }
    operator_chart = {
      repository = "${local.operator_chart.url}@${local.operator_chart.ref.digest}"
    }
  }

  managed_resources = {
    secrets_yaml = yamlencode({
      apiVersion = "v1"
      kind       = "Secret"
      metadata = {
        name      = "sops-age"
        namespace = "flux-system"
      }
      stringData = {
        "age.agekey" = var.sops_age_key
      }
    })
    runtime_info = {
      labels = {
        "reconcile.fluxcd.io/watch" = "Enabled"
      }
      data = {
        cluster_name = var.cluster_name
      }
    }
  }
}
