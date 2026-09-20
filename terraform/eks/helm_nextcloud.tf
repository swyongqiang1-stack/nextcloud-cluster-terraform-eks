resource "helm_release" "nextcloud" {
  name       = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  version    = "9.2.6"
  namespace = local.namespace.nextcloud_namespace

  values = [
    file("${path.module}/../values/nextcloud.yaml")
  ]
}
