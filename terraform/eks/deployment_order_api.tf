resource "kubernetes_deployment" "order-api" {
  metadata {
    name = "order-api"
    namespace = "dev"
    labels = {
      app = "order-api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "order-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "order-api"
        }
      }

      spec {
        container {
          image = "nicolaka/netshoot"
          name  = "order-api"

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