resource "helm_release" "nextcloud" {
  name       = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  version    = "9.2.6"
  namespace = "nextcloud"

  values = [
    file("${path.module}/values/nextcloud.yaml")
  ]
}
