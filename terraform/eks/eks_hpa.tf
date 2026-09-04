resource "kubernetes_horizontal_pod_autoscaler" "nextcloud" {
  metadata {
    name = "nextcloud"
  }

  spec {
    min_replicas = 1
    max_replicas = 3

    scale_target_ref {
      kind = "Deployment"
      name = "nextcloud"
    }

    metric {
      type = "resource"
      resource {
        name = "cpu"
        target {
          type  = "Utilization"
          value = "70"
        }
      }

      }
        
    behavior {
      scale_up {
        stabilization_window_seconds = 0
        select_policy                = "max"
        policy {
          period_seconds = 60
          type           = "Pods"
          value          = 4
        }

        policy {
          period_seconds = 60
          type           = "Percent"
          value          = 50
        }
      }
      
      scale_down {
        stabilization_window_seconds = 600
        select_policy                = "min"
        policy {
          period_seconds = 60
          type           = "Percent"
          value          = 100
        }
        policy {
          period_seconds = 60
          type           = "pods"
          value          = 3
        }
        }
      }
    }
  }

