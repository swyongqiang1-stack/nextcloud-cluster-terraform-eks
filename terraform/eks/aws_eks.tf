resource "aws_eks_cluster" "nextcloud" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.35"

  vpc_config {
    subnet_ids = module.vpc.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}




resource "aws_iam_role" "cluster" {
  name = "eks-cluster-nextcloud"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_ec2_tag" "eks_security_group_discovery" {
  resource_id = aws_eks_cluster.nextcloud.vpc_config[0].cluster_security_group_id

  key   = "karpenter.sh/discovery"
  value = aws_eks_cluster.nextcloud.name
}