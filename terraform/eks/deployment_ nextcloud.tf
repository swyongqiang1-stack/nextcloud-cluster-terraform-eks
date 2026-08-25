resource "kubernetes_deployment" "nextcloud" {
  metadata {
    name = "nextcloud"
    namespace = "dev"
    labels = {
      app = "nextcloud"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nextcloud"
      }
    }

    template {
      metadata {
        labels = {
          app = "nextcloud"
        }
      }

      spec {
        container {
          image = "nextcloud:alpine"
          name  = "nextcloud"

          resources {
            limits = {
              cpu    = "4000m"
              memory = "8Gi"
            }
            requests = {
              cpu    = "2000m"
              memory = "4Gi"
            }
          }
          port {
            container_port = 80
          } 
          }
        }
      }
    }
}


resource "kubernetes_service" "nextcloud" {
  metadata {
    name = "nextcloud"
    namespace = "dev"
  }
  spec {
    selector = {
      app = "nextcloud"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}




#还没做以下
#POSTGRES_HOST=postgres
#持久化
