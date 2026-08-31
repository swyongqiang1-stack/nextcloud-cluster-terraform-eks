resource "helm_release" "Karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/karpenter"
  chart            = "karpenter"
  version          = "1.14.1"
  namespace        = "kube-system"
  create_namespace = true

    set {
        name = "serviceAccount.annotations.eks.amazonaws.com/role-arn"
        value = "karpenter"
 } 
   set {
    name  = "serviceAccount.create"
    value = "false"
  }
    set {
        name = "settings.clusterName"
        value = "nextcloud"
 }
    set {
        name = "settings.interruptionQueue"
        value = "nextcloud"
    }
}