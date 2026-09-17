resource "helm_release" "Karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/karpenter"
  chart            = "karpenter"
  version          = "1.14.1"
  namespace        = "kube-system"

    set {
    name  = "serviceAccount.create"
    value = "false"
    }

    set {
        name = "serviceAccount.name"
        value = "karpenter-controller"
    }

    set {
        name = "settings.clusterName"
        value = "nextcloud"
    }

}