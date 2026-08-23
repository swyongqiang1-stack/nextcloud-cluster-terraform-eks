resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3-retain"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp3"
  }
}


