resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "v0.93.1"
  namespace = "monitoring"
  

  values = [
    file("${path.module}/values/prometheus.yaml")
  ]
}
