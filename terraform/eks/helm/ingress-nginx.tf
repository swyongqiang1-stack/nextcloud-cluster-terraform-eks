resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  values = [
    file("${path.module}/values/ingress_nginx.yaml")
  ]

}

resource "kubernetes_ingress_v1" "nextcloud" {
  wait_for_load_balancer = true
  metadata {
    name = "nextcloud"
    namespace = "nextcloud"
    annotations = {
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
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
              name = "nextcloud"
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