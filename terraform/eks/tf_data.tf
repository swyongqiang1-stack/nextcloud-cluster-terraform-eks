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
    namespace = local.namespace.nextcloud_namespace
  }
  depends_on = [ 
    helm_release.nextcloud
   ]
}


data "kubernetes_service_v1" "ingress_nginx" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = local.namespace.ingress_nginx_namespace
  }
  depends_on = [ 
    helm_release.ingress_nginx
   ]
}

data "aws_eks_cluster" "nextcloud" {
  name = local.cluster_name
}



data "aws_caller_identity" "current" {}