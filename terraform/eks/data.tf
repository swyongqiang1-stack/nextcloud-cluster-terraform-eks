data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }

  depends_on = [
    aws_eks_cluster.nextcloud
  ]
}


data "kubernetes_service_v1" "nextcloud" {
  metadata {
    name = "nextcloud"
    namespace = local.nextcloud_namespace
  }
}
