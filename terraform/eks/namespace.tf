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
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn" = "v1.31"
      "name" = "ingress-nginx"
      "kubernetes.io/metadata.name" = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}