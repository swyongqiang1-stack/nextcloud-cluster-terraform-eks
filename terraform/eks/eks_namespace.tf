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

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    labels = {
      "name" = "ingress-nginx"
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/warn" = "restricted"
      "kubernetes.io/metadata.name" = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}