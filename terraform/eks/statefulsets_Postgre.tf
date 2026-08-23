resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
    namespace = "dev"
  }
  spec {
    service_name = "postgres"
    replicas = 1            #不做集群数据库，仅做测试，所以设置 1 个副本数
    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        toleration {
          key = "workload"
          value = "database"
          effect = "NoSchedule"
          operator = "Equal"
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "workload"
                  values = ["database"] 
                  operator = "in"
                }
              }
            }
          }
        }
        container {
          name  = "postgres"
          image = "postgres:16"
          port {
            container_port = 5432
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "gp3-retain"

        resources {
          requests = {
            storage = "100Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    namespace = "dev"
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    cluster_ip = "None"
  }
}