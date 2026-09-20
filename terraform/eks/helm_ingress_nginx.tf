resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress-nginx.metadata[0].name
  values = [
    file("${path.module}/values_ingress_nginx.yaml")
  ]
  depends_on = [ 
    aws_eks_cluster.nextcloud
  ]

}

resource "kubernetes_ingress_v1" "ingress_nginx_alb" {
  wait_for_load_balancer = true
  metadata {
    name = "ingress-nginx-alb"
    namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
    annotations = {
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
    "external-dns.alpha.kubernetes.io/hostname" = local.domain_name
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
      {
        HTTP = 80
      },
      {
        HTTPS = 443
      }
    ])

    "alb.ingress.kubernetes.io/certificate-arn" =  local.iam_arn

    "alb.ingress.kubernetes.io/ssl-redirect" = "443"
}

  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = data.kubernetes_service_v1.ingress_nginx.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}




resource "kubernetes_ingress_v1" "nextcloud" {
  metadata {
    name = "nextcloud-ingress"
    namespace = kubernetes_namespace.nextcloud.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/affinity" = "cookie"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "X-Forwarded-For"

      }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.domain_name
      http {
        path {
          path = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = data.kubernetes_service_v1.nextcloud.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

