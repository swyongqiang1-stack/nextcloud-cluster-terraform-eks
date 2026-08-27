resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
      name  = "controller.service.type"
      value = "LoadBalancer"
    }

  set {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "external"
  }
  set {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
      value = "ip"
  }
  
  set {    
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internet-facing"
}
  set{
      name  = "controller.metrics.enabled"
      value = "true"
  }
  set{
      name  = "controller.metrics.serviceMonitor.enabled"
      value = "true"
  }
}

resource "kubernetes_ingress_v1" "nextcloud" {
  wait_for_load_balancer = true
  metadata {
    name = "nextcloud"
    namespace = "dev"
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