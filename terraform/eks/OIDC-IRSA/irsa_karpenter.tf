resource "aws_iam_openid_connect_provider" "cluster" {
  url = "https://oidc.eks.ap-southeast-1.amazonaws.com/id/留空"
#aws eks describe-cluster --name 集群名 --query "cluster.identity.oidc.issuer"
#取上面的 id 复制进去
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}


resource "aws_iam_role" "karpenter" {
  name = "eks_karpenter_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:kube-system:karpenter"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "karpenter" {
  name = "karpenter_policy"
  role = aws_iam_role.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeCapacityReservations",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}




resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"   
    namespace = "kube-system"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter.arn  
    }
  }
}




resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-nextcloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}