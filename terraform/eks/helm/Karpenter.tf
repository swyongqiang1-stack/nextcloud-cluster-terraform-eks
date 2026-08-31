resource "helm_release" "Karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/karpenter"
  chart            = "karpenter"
  version          = "1.14.1"
  namespace        = "karpenter"
  create_namespace = true

    set {
        serviceAccount.annotations.eks\.amazonaws\.com/role-arn=""
 } 
    set {
        settings.clusterName = 
 }
}