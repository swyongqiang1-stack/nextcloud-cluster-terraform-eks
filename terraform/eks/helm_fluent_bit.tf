resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = "0.58.1"
  namespace        = var.nextcloud_namespace
  values = [
    file("${path.module}/../values/fluent_bit.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = "false"
    }
    
  set {
    name = "serviceAccount.name"
    value = var.fluent_bit_sa
  }

}
