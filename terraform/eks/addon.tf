resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.e_cm.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "proxy" {
  cluster_name = aws_eks_cluster.e_cm.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "dns" {
  cluster_name = aws_eks_cluster.e_cm.name
  addon_name   = "coredns"
}


resource "aws_eks_addon" "csi" {
  cluster_name = aws_eks_cluster.e_cm.name
  addon_name   = "aws-ebs-csi-driver"
}