

resource "kubernetes_resource_quota" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = local.namespace.nextcloud_namespace
  }
  spec {
    hard = {
      pods   = 100
      cpu    = "100"
      memory = "200Gi"
    }

  }
}


resource "kubernetes_limit_range" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = local.namespace.nextcloud_namespace
  }
  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = "4000m"
        memory = "4G"
      }
    }

    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "250Mi"
      }
    }
  }
}

