locals {
  nextcloud_namespace = kubernetes_namespace.nextcloud.metadata[0].name
}



locals{
  external_secrets_namespace = kubernetes_namespace.external_secrets.metadata[0].name
}


locals {
  cluster_name = aws_eks_cluster.nextcloud.name
}

locals{
  ingress_nginx_namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
}