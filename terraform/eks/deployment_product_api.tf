resource "kubernetes_deployment" "product_api" {
  metadata {
    name = "product_api"
    namespace = "dev"
    labels = {
      app = "product_api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "product_api"
      }
    }

    template {
      metadata {
        labels = {
          app = "product_api"
        }
      }

      spec {
        container {
          image = "nicolaka/netshoot"
          name  = "product_api"

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