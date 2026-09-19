resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.9.0"
  namespace        = var.external_secrets_namespace
  create_namespace = false

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = var.eso_sa
  }
  
}


