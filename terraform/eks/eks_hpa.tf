resource "kubernetes_horizontal_pod_autoscaler_v2" "nextcloud" {
  metadata {
    name      = "nextcloud-hpa"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 10

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "nextcloud"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }

    }

  }
}
# i don't want to add behavior,i can not understanding it how to work on best condition
