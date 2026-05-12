resource "harbor_robot_account" "k8s" {
  name   = "k8s"
  level  = "system"

  secret_wo         = var.robot_account_k8s_secret
  secret_wo_version = parseint(substr(md5(var.robot_account_k8s_secret), 0, 8), 16)

  dynamic "permissions" {
    for_each = harbor_project.proxy_cache
    content {
      kind      = "project"
      namespace = permissions.value.name

      access {
        action   = "pull"
        resource = "repository"
      }
      access {
        action   = "list"
        resource = "repository"
      }

      access {
        action   = "read"
        resource = "artifact"
      }
      access {
        action   = "list"
        resource = "artifact"
      }

      access {
        action   = "read"
        resource = "helm-chart"
      }

      access {
        action   = "list"
        resource = "tag"
      }
    }
  }
}
