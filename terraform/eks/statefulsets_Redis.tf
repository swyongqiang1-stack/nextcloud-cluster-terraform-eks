resource "kubernetes_stateful_set" "redis" {
  metadata {
    name = "redis"
    namespace = "dev"
  }
  spec {
    service_name = "redis"
    replicas = 1        #不做集群数据库，仅做测试，所以设置 1 个副本数

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        toleration {
          key = "workload"
          value = "database"
          effect = "NoSchedule"
          operator = "Equal"
        }
        container {
          name  = "redis"
          image = "redis:7"
        port {
          container_port = 6379
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "redis-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "gp3-retain"

        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    namespace = "dev"
  }
  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    cluster_ip = "None"
  }
}