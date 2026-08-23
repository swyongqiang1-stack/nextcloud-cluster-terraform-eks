resource "kubernetes_namespace" "dev" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/warn" = "restricted"
    }

    name = "dev"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/warn" = "restricted"
    }

    name = "prod"
  }
}

