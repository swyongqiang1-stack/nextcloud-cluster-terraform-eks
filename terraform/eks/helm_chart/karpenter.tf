resource "helm_release" "Karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/karpenter"
  chart            = "karpenter"
  version          = "1.14.1"
  namespace        = "kube-system"
  depends_on = [
    kubernetes_service_account.karpenter-controller
  ]
    set {
    name = "instanceProfile"
    value  = "KarpenterNodeInstanceProfile-nextcloud"
    }
  
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

    set {
        name = "settings.interruptionQueue"
        value = "nextcloud"
    }
    set {
        name = "serviceMonitor.enabled"
        value = "true"
    }

    set {
        name = "serviceMonitor.additionalLabels.release"
        value = "prometheus"
    }
}