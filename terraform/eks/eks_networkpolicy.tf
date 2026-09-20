
resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name      = "default-deny-all"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {}

    policy_types = [
      "Ingress",
      "Egress"
    ]
  }
}


resource "kubernetes_network_policy" "allow_dns" {
  metadata {
    name      = "allow-dns"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {}

    policy_types = [
      "Egress"
    ]

    egress {
      to {
        namespace_selector {}

        pod_selector {
          match_labels = {
            "k8s-app" = "kube-dns"
          }
        }
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }

      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}



resource "kubernetes_network_policy" "nextcloud" {
  metadata {
    name      = "nextcloud-policy"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "nextcloud"
      }
    }

    policy_types = [
      "Ingress",
      "Egress"
    ]


    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }


        pod_selector {
          match_labels = {
            "app.kubernetes.io/name"      = "ingress-nginx"
            "app.kubernetes.io/component" = "controller"
          }
        }
       }
       
      ports {
        protocol = "TCP"
        port     = "80"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "database"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "redis"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "6379"
      }
    }

    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"

          except = [
            "169.254.169.254/32"
          ]
        }
      }

      ports {
        protocol = "TCP"
        port     = "443"
      }
    }
  }
}



resource "kubernetes_network_policy" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = local.namespace.nextcloud_namespace
    
  }

  spec {
    pod_selector {
        match_labels = {
          app = "database"
      }
    }

    policy_types = [
      "Ingress"
    ]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app" = "nextcloud"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
  }
}



resource "kubernetes_network_policy" "redis" {
  metadata {
    name      = "redis"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {
        match_labels = {
          app = "redis"
      }
    }

    policy_types = [
      "Ingress"
    ]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app" = "nextcloud"
          }
        }
      }
      
      ports {
        protocol = "TCP"
        port     = "6379"
      }
    }
  }
}




resource "kubernetes_network_policy" "postgresql_back" {
  metadata {
    name      = "postgresql-back"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {
        match_labels = {
          app = "database"
      }
    }

    policy_types = [
      "Ingress"
    ]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app" = "database-backup"
          }
        }
      }
      
      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
  }
}




resource "kubernetes_network_policy" "cronjob_access" {
  metadata {
    name      = "cronjob"
    namespace = local.namespace.nextcloud_namespace
  }

  spec {
    pod_selector {
        match_labels = {
          app = "database-backup"
      }
    }

    policy_types = [
      "Egress"
    ]
    egress {
      to {
        pod_selector {
          match_labels = {
            app = "database"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
    
    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"

          except = [
            "169.254.169.254/32"
          ]
        }
      }

      ports {
        protocol = "TCP"
        port     = "443"
      }
    }
  }
}