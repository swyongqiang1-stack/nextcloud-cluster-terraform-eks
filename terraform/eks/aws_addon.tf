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

  pod_identity_association {
    role_arn        = module.aws_iam_role.nextcloud_ebs.arn
    service_account = ebs-csi-controller-sa
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    module.aws_iam_role_policy.nextcloud_ebs
  ]

}


resource "aws_eks_addon" "efs_csi" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "aws-efs-csi-driver"
    pod_identity_association {
    role_arn        = module.aws_iam_role.nextcloud_efs.arn
    service_account = efs-csi-controller-sa
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    module.aws_iam_role_policy.nextcloud_efs
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.nextcloud.name
  addon_name   = "eks-pod-identity-agent"
}