resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "dev"
  }

  spec {
    service_name = "postgres"
    replicas     = 1

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
          key      = "workload"
          value    = "database"
          effect   = "NoSchedule"
          operator = "Equal"
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "workload"
                  values   = ["database"]
                  operator = "In"
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

          env {
            name = "POSTGRES_USER"

            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "password"
              }
            }
          }

          env {
            name = "POSTGRES_DB"

            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "dbname"
              }
            }
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
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
    name      = "postgres"
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