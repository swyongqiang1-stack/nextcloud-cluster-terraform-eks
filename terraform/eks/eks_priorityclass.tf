resource "kubernetes_priority_class_v1" "high" {
  metadata {
    name = "high-priority"
  }

  value = 100
}