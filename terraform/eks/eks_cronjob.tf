
resource "kubernetes_cron_job_v1" "backup_database" {
  metadata {
    name      = "backup-database"
    namespace = "nextcloud"

  }

  spec {
    schedule           = "0 2 * * *"
    timezone          = "Asia/Singapore"
    concurrency_policy = "Forbid"

    job_template {
      metadata {
      }

      spec {
        backoff_limit = 2

        template {
          metadata {
            labels = {
              app = "database-backup"
    }
          }

          spec {
            service_account_name = "postgres-backup"
            restart_policy       = "Never"

            container {
              name  = "postgres-backup"
              image = "your-ecr-url/postgres-backup:version-tag"

              command = [
                "/bin/sh",
                "/scripts/backup.sh"
              ]

              env_from {
                secret_ref {
                  name = "postgresql-secret"
                }
                config_map_ref {
                  name = "postgres-backup-config"
                }
              }
              volume_mount {
                name = "backup-script"
                mount_path = "/scripts"
              }
            }
            volume {
              name = "backup-script"
              config_map {
                name = postgres-backup-script
              }
            }
          }
        }
      }
    }
  }
}