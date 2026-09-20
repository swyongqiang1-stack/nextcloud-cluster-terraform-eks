locals{
  namespace = {
    nextcloud_namespace = kubernetes_namespace.nextcloud.metadata[0].name
    ingress_nginx_namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
    kube_system_namespace = data.kubernetes_namespace.kube_system.metadata[0].name
  }
}


locals {
  cluster_name = aws_eks_cluster.nextcloud.name
}

