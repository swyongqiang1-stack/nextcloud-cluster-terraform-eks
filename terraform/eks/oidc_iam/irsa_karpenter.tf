resource "aws_iam_role" "karpenter_controller" {
  name = "eks_karpenter_controller_role"

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
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:kube-system:karpenter-controller"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter_controller_policy"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowScopedEC2InstanceAccessActions"
        Effect = "Allow"

        Resource = [
          "arn:aws:ec2:ap-southeast-1::image/*",
          "arn:aws:ec2:ap-southeast-1::snapshot/*",
          "arn:aws:ec2:ap-southeast-1:*:security-group/*",
          "arn:aws:ec2:ap-southeast-1:*:subnet/*",
          "arn:aws:ec2:ap-southeast-1:*:capacity-reservation/*",
          "arn:aws:ec2:ap-southeast-1:*:placement-group/*"
        ]

        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
      },

      {
        Sid    = "AllowScopedEC2LaunchTemplateAccessActions"
        Effect = "Allow"

        Resource = "arn:aws:ec2:ap-southeast-1:*:launch-template/*"

        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]

        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/nextcloud" = "owned"
          }

          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      },

      {
        Sid    = "AllowScopedEC2InstanceActionsWithTags"
        Effect = "Allow"

        Resource = [
          "arn:aws:ec2:ap-southeast-1:*:fleet/*",
          "arn:aws:ec2:ap-southeast-1:*:instance/*",
          "arn:aws:ec2:ap-southeast-1:*:volume/*",
          "arn:aws:ec2:ap-southeast-1:*:network-interface/*",
          "arn:aws:ec2:ap-southeast-1:*:launch-template/*",
          "arn:aws:ec2:ap-southeast-1:*:spot-instances-request/*"
        ]

        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate"
        ]

        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/nextcloud" = "owned"
            "aws:RequestTag/eks:eks-cluster-name"    = "nextcloud"
          }

          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
      },

      {
        Sid    = "AllowScopedResourceCreationTagging"
        Effect = "Allow"

        Resource = [
          "arn:aws:ec2:ap-southeast-1:*:fleet/*",
          "arn:aws:ec2:ap-southeast-1:*:instance/*",
          "arn:aws:ec2:ap-southeast-1:*:volume/*",
          "arn:aws:ec2:ap-southeast-1:*:network-interface/*",
          "arn:aws:ec2:ap-southeast-1:*:launch-template/*",
          "arn:aws:ec2:ap-southeast-1:*:spot-instances-request/*"
        ]

        Action = "ec2:CreateTags"

        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/nextcloud" = "owned"
            "aws:RequestTag/eks:eks-cluster-name" = "nextcloud"

            "ec2:CreateAction" = [
              "RunInstances",
              "CreateFleet",
              "CreateLaunchTemplate"
            ]
          }

          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
      },

      {
        Sid      = "AllowScopedResourceTagging"
        Effect   = "Allow"
        Resource = "arn:aws:ec2:ap-southeast-1:*:instance/*"
        Action   = "ec2:CreateTags"

        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/nextcloud" = "owned"
          }

          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }

          StringEqualsIfExists = {
            "aws:RequestTag/eks:eks-cluster-name" = "nextcloud"
          }

          "ForAllValues:StringEquals" = {
            "aws:TagKeys" = [
              "eks:eks-cluster-name",
              "karpenter.sh/nodeclaim",
              "Name"
            ]
          }
        }
      },

      {
        Sid    = "AllowScopedDeletion"
        Effect = "Allow"

        Resource = [
          "arn:aws:ec2:ap-southeast-1:*:instance/*",
          "arn:aws:ec2:ap-southeast-1:*:launch-template/*"
        ]

        Action = [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ]

        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/nextcloud" = "owned"
          }

          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      }
    ]
  })
}







resource "kubernetes_service_account" "karpenter_controller" {
  metadata {
    name      = "karpenter-controller"   
    namespace = "kube-system"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn 
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


resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter_node"
  role = aws_iam_role.karpenter_node.name
}