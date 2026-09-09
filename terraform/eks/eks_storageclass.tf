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


resource "aws_security_group" "allow_efs" {
  name        = "allow_efs"
  description = "Allow access efs file system"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_efs.id
  cidr_ipv4         = module.vpc.vpc_id
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
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



