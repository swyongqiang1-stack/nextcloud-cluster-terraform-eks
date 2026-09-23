resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.58.1"
  namespace  = local.namespace.nextcloud_namespace
  values = [
    file("${path.module}/values_fluent_bit.yaml")
  ]
  depends_on = [
    aws_eks_cluster.nextcloud,
    aws_eks_pod_identity_association.fluent_bit
  ]

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.fluent_bit.metadata[0].name
  }
  set {
    name  = "labels.app"
    value = "fluent-bit"
  }
  set {
    name  = "podLabels.app"
    value = "fluent-bit"
  }
}
