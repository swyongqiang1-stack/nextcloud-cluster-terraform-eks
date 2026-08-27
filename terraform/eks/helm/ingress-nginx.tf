resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  values = [
    file("${path.module}/values/ingress_nginx.yaml")
  ]

resource "kubernetes_ingress_v1" "nextcloud" {
  wait_for_load_balancer = true
  metadata {
    name = "nextcloud"
    namespace = "nextcloud"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/*"
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