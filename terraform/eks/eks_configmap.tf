resource "kubernetes_config_map_v1" "postgres_backup_config" {
  metadata {
    name = "postgres-backup-config"
    namespace = "nextcloud"
  }

  data = {
    POSTGRES_HOST             = "nextcloud-postgresql"
    POSTGRES_DB              = "nextcloud"
    BACKUP_BUCKET            = aws_s3_bucket.postgresql_back.bucket
  }
}


resource "kubernetes_config_map_v1" "postgres_backup_script" {
  metadata {
    name = "postgres-backup-script"
    namespace = "nextcloud"
  }

  data = {
    "backup.sh" = <<-EOT
      #!/bin/sh
      set -e

      BACKUP_FILE="nextcloud-$(date +%Y%m%d-%H%M%S).sql.gz"

      echo "Starting PostgreSQL backup..."

      pg_dump \
        -h "$POSTGRES_HOST" \
        -U "$POSTGRES_USER" \
        -d "$POSTGRES_DB" \
      | gzip \
      | aws s3 cp - \
        "s3://$BACKUP_BUCKET/postgresql/$BACKUP_FILE"

      echo "Backup completed: $BACKUP_FILE"
    EOT

  }
}