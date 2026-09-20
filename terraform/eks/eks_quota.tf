

resource "kubernetes_resource_quota" "nextcloud" {
  metadata {
    name = "nextcloud"
    namespace = local.namespace.nextcloud_namespace
  }
  spec {
    hard = {
      pods = 20
      cpu = "20"        
      memory = "20Gi"  
    }

  }
}


resource "kubernetes_limit_range" "nextcloud" {
  metadata {
    name = "nextcloud"
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
        cpu    = "3000m"
        memory = "3000Mi"
      }
    }
  }
    }

