
resource "kubernetes_resource_quota" "dev" {
  metadata {
    name = "dev"
    namespace = "dev"
  }
  spec {
    hard = {
      pods = 30
      cpu = "16"        
      memory = "32Gi"  
    }

  }
}


resource "kubernetes_limit_range" "dev" {
  metadata {
    name = "dev"
    namespace = "dev"
  }
  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = "4000m"
        memory = "8G"
      }
    }

    limit {
      type = "Container"
      default = {
        cpu    = "250m"
        memory = "256Mi"
      }
    }
  }
    }

