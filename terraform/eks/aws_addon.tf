resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "vpc-cni"
  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })
}

resource "aws_eks_addon" "proxy" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "dns" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "coredns"
}


resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "aws-ebs-csi-driver"
}


resource "aws_eks_addon" "efs_csi" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "aws-efs-csi-driver"
}

resource "aws_eks_addon" "s3_csi" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "aws-efs-csi-driver"
}