provider "harbor" {
  url      = var.harbor_url
  username = var.harbor_username
  password = var.harbor_password
  insecure = false
}

locals {
  registries = {
    dockerhub-upstream = {
      provider_name = "docker-hub"
      endpoint_url  = "https://hub.docker.com"
      access_id     = var.dockerhub_access_id
      access_secret = var.dockerhub_access_secret
    }
    ghcr-upstream = {
      provider_name = "github"
      endpoint_url  = "https://ghcr.io"
      access_id     = var.ghcr_access_id
      access_secret = var.ghcr_access_secret
    }
    quay-registry-upstream = {
      provider_name = "docker-registry"
      endpoint_url  = "https://quay.io"
      access_id     = var.quay_access_id
      access_secret = var.quay_access_secret
    }
    k8s-registry-upstream = {
      provider_name = "docker-registry"
      endpoint_url  = "https://registry.k8s.io"
      access_id     = ""
      access_secret = ""
    }
    gcr-registry-upstream = {
      provider_name = "docker-registry"
      endpoint_url  = "https://gcr.io"
      access_id     = var.gcr_access_id
      access_secret = var.gcr_access_secret
    }
    mcr-upstream = {
      provider_name = "docker-registry"
      endpoint_url  = "https://mcr.microsoft.com"
      access_id     = ""
      access_secret = ""
    }
  }

  projects = {
    dockerhub = {
      registry = "dockerhub-upstream"
    }
    ghcr = {
      registry = "ghcr-upstream"
    }
    quay = {
      registry = "quay-registry-upstream"
    }
    registry-k8s = {
      registry = "k8s-registry-upstream"
    }
    gcr = {
      registry = "gcr-registry-upstream"
    }
    mcr = {
      registry = "mcr-upstream"
    }
  }
}

resource "harbor_registry" "proxy" {
  for_each = local.registries

  name          = each.key
  provider_name = each.value.provider_name
  endpoint_url  = each.value.endpoint_url
  insecure      = false

  access_id     = each.value.access_id != "" ? each.value.access_id : null
  access_secret = each.value.access_secret != "" ? each.value.access_secret : null
}

resource "harbor_project" "proxy_cache" {
  for_each = local.projects

  name           = each.key
  public         = false
  registry_id    = harbor_registry.proxy[each.value.registry].registry_id
  proxy_speed_kb = -1
}
