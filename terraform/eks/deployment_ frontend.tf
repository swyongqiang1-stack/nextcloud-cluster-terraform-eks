resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    namespace = "dev"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "frontend"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
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
