resource "kubernetes_deployment" "user-api" {
  metadata {
    name = "user-api"
    namespace = "dev"
    labels = {
      app = "user-api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "user-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "user-api"
        }
      }

      spec {
        container {
          image = "nicolaka/netshoot"
          name  = "user-api"

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
          }
        }
      }
    }
}