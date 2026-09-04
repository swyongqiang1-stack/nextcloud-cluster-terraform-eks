resource "kubernetes_cron_job_v1" "backup_database" {
  metadata {
    name      = "backup-database"
    namespace = "dev"
  }

  spec {
    
    schedule = "0 2 * * *"

    timezone = "Asia/Singapore"

    concurrency_policy = "Forbid"

    failed_jobs_history_limit     = 3
    successful_jobs_history_limit = 3

    job_template {
      metadata {}

      spec {
        
        backoff_limit = 2

        template {
          metadata {}

          spec {
            
            service_account_name = "postgres-backup"

            init_container {
              name  = "pg-dump"
              image = "postgres:17"

              command = [
                "/bin/sh",
                "-c",
                <<-EOT
                  set -e

                  echo "Starting PostgreSQL backup..."

                  pg_dump \
                    -h "unknowname" \             #unknowname dns name, utill service online
                    -U "$POSTGRES_USER" \
                    -d "$POSTGRES_DB" \
                    | gzip > /backup/nextcloud-$(date +%Y%m%d-%H%M%S).sql.gz

                  echo "PostgreSQL backup completed."
                EOT
              ]

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
                    key  = "database"
                  }
                }
              }

              volume_mount {
                name       = "backup"
                mount_path = "/backup"
              }
            }

            container {
              name  = "upload-s3"
              image = "public.ecr.aws/aws-cli/aws-cli:latest"

              command = [
                "/bin/sh",
                "-c",
                <<-EOT
                  set -e

                  echo "Uploading backup to S3..."

                  aws s3 cp \
                    /backup/ \
                    s3://YOUR-BACKUP-BUCKET/postgresql/ \           #have to edit s3 name
                    --recursive

                  echo "Upload completed."
                EOT
              ]

              volume_mount {
                name       = "backup"
                mount_path = "/backup"
              }
            }

            volume {
              name = "backup"

              empty_dir {}
            }

            restart_policy = "Never"
          }
        }
      }
    }
  }
}


#above is ai writing


