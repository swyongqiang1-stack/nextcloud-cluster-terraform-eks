resource "helm_release" "Karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/"
  chart            = "karpenter"
  version          = "1.14.1"
  namespace        = local.namespace.kube_system_namespace
  depends_on = [ 
    aws_eks_cluster.nextcloud
  ]
    set {
    name  = "serviceAccount.create"
    value = "false"
    }

    set {
        name = "serviceAccount.name"
        value = kubernetes_service_account.karpenter_controller.metadata[0].name
    }

    set { 
        name = "settings.clusterName"
        value = local.cluster_name
    }

}