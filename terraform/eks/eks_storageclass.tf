resource "kubernetes_storage_class" "ebs_gp3" {
  metadata {
    name = "ebs-gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp3"
  }
}





resource "aws_efs_file_system" "nextcloud_efs" {
  encrypted = true
}


resource "kubernetes_storage_class" "nextcloud_efs" {
  metadata {
    name = "nextcloud-efs"
  }
  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.nextcloud_efs.id
    directoryPerms   = "750"
  }
}



