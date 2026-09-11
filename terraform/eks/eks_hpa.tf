resource "kubernetes_horizontal_pod_autoscaler_v2" "nextcloud" {
  metadata {
    name = "nextcloud-hpa"
    namespace = "nextcloud"
  }

  spec {
    min_replicas = 3
    max_replicas = 6

    scale_target_ref {
      kind = "Deployment"
      name = "nextcloud"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type  = "Utilization"
          value = "70"
        }
      }

      }

  }

# i don't want to add behavior,i can not understanding it how to work on best condition
