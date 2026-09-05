resource "helm_release" "external_secrets" {
  name             = "external_secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.9.0"
  namespace        = "external_secrets"
  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  depends_on = [
    kubernetes_service_account.external_secrets
  ]
}


