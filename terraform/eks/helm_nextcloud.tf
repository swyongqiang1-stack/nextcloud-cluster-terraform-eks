resource "helm_release" "nextcloud" {
  name       = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  version    = "9.2.6"
  namespace = local.namespace.nextcloud_namespace
  depends_on = [ 
    aws_eks_cluster.nextcloud
  ]
  values = [
    file("${path.module}/values_nextcloud.yaml")
  ]
}
