resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  values = [
    file("${path.module}/../values/ingress_nginx.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = "false"
    }
    
    
}

resource "kubernetes_ingress_v1" "ingress_nginx_alb" {
  wait_for_load_balancer = true
  metadata {
    name = "ingress-nginx-alb"
    namespace = "ingress-nginx"
    annotations = {
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
    "external-dns.alpha.kubernetes.io/hostname" = "www.erben.cn"
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
      {
        HTTP = 80
      },
      {
        HTTPS = 443
      }
    ])

    "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-southeast-1:463884819678:certificate/1880b9bc-3df9-416c-bc43-97e6a8851050"   # your acm domain arn

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
              name = "ingress-nginx-controller"
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
    namespace = "nextcloud"
    annotations = {
      "nginx.ingress.kubernetes.io/affinity" = "cookie"
      "nginx.ingress.kubernetes.io/server-snippet" = <<-EOT
      server_tokens off;
      proxy_hide_header X-Powered-By;

      rewrite ^/.well-known/webfinger /index.php/.well-known/webfinger last;
      rewrite ^/.well-known/nodeinfo /index.php/.well-known/nodeinfo last;
      rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
      rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json;

      location = /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
      }

      location = /.well-known/caldav {
        return 301 $scheme://$host/remote.php/dav;
      }

      location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
      }

      location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
        deny all;
      }

      location ~ ^/(?:autotest|occ|issue|indie|db_|console) {
        deny all;
      }
    EOT
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "X-Forwarded-For"

      }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "erben.cn"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = "nextcloud"
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

