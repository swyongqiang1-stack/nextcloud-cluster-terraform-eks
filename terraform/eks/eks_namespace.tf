resource "kubernetes_namespace" "dev" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }

    name = "dev"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }

    name = "prod"
  }
}

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    labels = {
      "name"                               = "ingress-nginx"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
      "kubernetes.io/metadata.name"        = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}



resource "kubernetes_namespace" "nextcloud" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }

    name = "nextcloud"
  }
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }

    name = "external-secrets"
  }
}
