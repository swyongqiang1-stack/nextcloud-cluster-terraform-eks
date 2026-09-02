resource "kubernetes_priority_class" "high" {
  metadata {
    name = "high-priority"
  }

  value = 100
}