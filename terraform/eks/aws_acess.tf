resource "aws_eks_access_entry" "nextcloud" {
  cluster_name      = aws_eks_cluster.nextcloud.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
}

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = var.cluster_name
  principal_arn = module.oidc_iam.karpenter_node_arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_policy_association" "nextcloud" {
  cluster_name  = aws_eks_cluster.nextcloud.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"

  access_scope {
    type       = "cluster"
  }
}