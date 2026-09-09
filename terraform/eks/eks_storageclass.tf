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

resource "aws_efs_mount_target" "nextcloud_efs" {
  count = 3
  file_system_id = aws_efs_file_system.nextcloud_efs.id
  subnet_id      = module.vpc.private_subnet_ids[count.index]
  security_groups = [aws_security_group.nextcloud_efs.id]
}


resource "aws_security_group" "nextcloud_efs" {
  name        = "nextcloud_efs"
  description = "nextcloud node group access efs"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "nextcloud_efs_allow_access" {
  security_group_id = aws_security_group.nextcloud_efs.id

  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049
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



