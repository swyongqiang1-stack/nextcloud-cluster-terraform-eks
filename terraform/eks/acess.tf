resource "aws_eks_access_entry" "nextcloud" {
  cluster_name      = aws_eks_cluster.nextcloud.name
  principal_arn     = "arn:aws:iam::463884819678:user/terraform"
}



resource "aws_eks_access_policy_association" "nextcloud" {
  cluster_name  = aws_eks_cluster.nextcloud.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = "arn:aws:iam::463884819678:user/terraform"

  access_scope {
    type       = "cluster"
  }
}