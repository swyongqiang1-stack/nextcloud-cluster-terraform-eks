resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = "0.58.1"
  namespace        = "dev"
  values = [
    file("${path.module}/values/fluent_bit.yaml")
  ]
}
