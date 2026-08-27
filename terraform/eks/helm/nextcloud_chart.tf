resource "helm_release" "nextcloud" {
  name       = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  version    = "9.2.6"
  namespace = "nextcloud"

  set {
    name = "ingress.enabled"
    value = "true"
  }

  set {
    name = "ingress.path"
    value = "/"
  }
  set {
    name = "ingress.pathType"
    value = "Prefix"
  }

  values = [
    yamlencode({
      postgresql = {
        primary = {
          nodeSelector = {
            workload = "database"
          }

          tolerations = [
            {
              key      = "workload"
              operator = "Equal"
              value    = "database"
              effect   = "NoSchedule"
            }
          ]
        }
      }
    })
  ]

#postgresql config

  set {
    name  = "internalDatabase.enabled"
    value = "false"
  }

  set {
    name  = "externalDatabase.enabled"
    value = "true"
  }

  set {
    name  = "externalDatabase.type"
    value = "postgresql"
  }

  set {
    name  = "externalDatabase.host"
    value = "nextcloud-postgresql:5432"
  }

  set {
    name  = "externalDatabase.database"
    value = "nextcloud"
  }

  set {
    name  = "externalDatabase.user"
    value = "nextcloud"
  }

  set {
    name = "postgresql.enabled"
    value = "true"
  }

  set {
    name = "postgresql.metrics.enabled"
    value = "true"
  }

  set {
    name = "postgresql.global.postgresql.auth.existingSecret"
    value = "postgres-secret"
  }

  set {
  name  = "postgresql.global.postgresql.auth.username"
  value = "nextcloud"
}

  set {
    name  = "postgresql.global.postgresql.auth.secretKeys.adminPasswordKey"
    value = "postgres-password"
  }

  set {
    name  = "postgresql.global.postgresql.auth.secretKeys.userPasswordKey"
    value = "password"
  }

  set {
    name  = "postgresql.global.postgresql.auth.database"
    value = "nextcloud"
  }

  set {
    name  = "postgresql.primary.persistence.enabled"
    value = "true"
  }

  set {
    name = "postgresql.primary.persistence.storageClass"
    value = "gp3-retain"
  }

  set {
    name = "postgresql.primary.persistence.size"
    value = "100Gi"
  }


#next secret config

  set {
    name  = "nextcloud.existingSecret.enabled"
    value = "true"
  }

  set {
    name  = "nextcloud.existingSecret.secretName"
    value = "nextcloud-secret"
  }

  set {
    name  = "nextcloud.existingSecret.usernameKey"
    value = "username"
  }

  set {
    name  = "nextcloud.existingSecret.passwordKey"
    value = "password"
  }

##next persistence


  set {
    name = "persistence.enabled"
    value = "true"
  }

  set { 
    name = "persistence.storageClass"
    value = "gp3-retain"
  }

  set {
    name = "persistence.accessMode"
    value = "ReadWriteOnce"
  }
  set {
    name = "persistence.size"
    value = "10Gi"
  }
  set {
    name = "persistence.nextcloudData.enabled"
    value = "true"
  }

  set {
    name = "persistence.nextcloudData.storageClass"
    value = "gp3-retain"
  }
  set {
    name = "persistence.nextcloudData.accessMode"
    value = "ReadWriteOnce"
  }
  set {
    name = "persistence.nextcloudData.size"
    value = "50Gi"
  }
}

#redis config

  set {
    name = "redis.enabled"
    value = "true"
  }

  set {
    name = "redis.auth.enabled"
    
  }
  set {
    name = "redis.auth.existingSecret"
  }

  set {
    name = "redis.auth.existingSecretPasswordKey"
  }

  set {
    name = "redis.global.storageClass"
  }