resource "kubernetes_config_map_v1" "postgres_backup_config" {
  metadata {
    name      = "postgres-backup-config"
    namespace = local.namespace.nextcloud_namespace
  }

  data = {
    POSTGRES_HOST = "nextcloud-postgresql"
    POSTGRES_DB   = "nextcloud"
    BACKUP_BUCKET = local.backup_bucket
    BACKUP_PREFIX = local.backup_prefix
  }
}

resource "kubernetes_config_map_v1" "postgres_backup_script" {
  metadata {
    name      = "postgres-backup-script"
    namespace = local.namespace.nextcloud_namespace
  }
    data = {
      "backup.sh" = <<-EOT
        #!/bin/bash
        set -euo pipefail

        NAMESPACE="nextcloud"
        BACKUP_ID="$(date -u +%Y%m%d-%H%M%S)-$HOSTNAME"
        BACKUP_PATH="s3://$BACKUP_BUCKET/$BACKUP_PREFIX/$BACKUP_ID"

        POD=$(kubectl -n "$NAMESPACE" get pods \
          -l app=nextcloud \
          --field-selector=status.phase=Running \
          -o jsonpath='{.items[0].metadata.name}')

        test -n "$POD"

        occ() {
          kubectl -n "$NAMESPACE" exec "$POD" -c nextcloud -- \
            php /var/www/html/occ "$@"
        }

        occ status --output=json |
          jq -e '.installed == true and .maintenance == false' >/dev/null

        cleanup() {
          RESULT=$?
          trap - EXIT INT TERM

          if ! occ maintenance:mode --off; then
            echo "Failed to close maintenance mode, please manually check!" >&2
            RESULT=1
          fi

          exit "$RESULT"
        }

        trap cleanup EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM

        occ maintenance:mode --on

        kubectl -n "$NAMESPACE" exec "$POD" -c nextcloud -- \
          tar --acls --xattrs --numeric-owner \
            -C /var/www/html \
            -cf - config custom_apps themes data \
          | gzip \
          | aws s3 cp - "$BACKUP_PATH/nextcloud-files.tar.gz" \
              --expected-size 107374182400

        pg_dump \
          -h "$POSTGRES_HOST" \
          -U "$POSTGRES_USER" \
          -d "$POSTGRES_DB" \
          | gzip \
          | aws s3 cp - "$BACKUP_PATH/database.sql.gz" \
              --expected-size 107374182400

        occ maintenance:mode --off
        trap - EXIT INT TERM

        echo "Backup completed" |
          aws s3 cp - "$BACKUP_PATH/COMPLETE"

        echo "backup finished：$BACKUP_PATH"
      EOT
    }
}


