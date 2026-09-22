resource "aws_eks_access_entry" "nextcloud" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
}

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = local.cluster_name
  principal_arn = aws_iam_role.karpenter_controller.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_policy_association" "nextcloud" {
  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"

  access_scope {
    type = "cluster"
  }
}