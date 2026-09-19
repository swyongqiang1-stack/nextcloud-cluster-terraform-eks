resource "aws_iam_role" "karpenter_controller" {
  name = "eks-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "pods.eks.amazonaws.com"
      }

      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}


resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter_controller_policy"
  role = aws_iam_role.karpenter_controller.id

        policy = jsonencode({
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "AllowScopedEC2InstanceAccessActions",
              "Effect": "Allow",
              "Resource": [
                "arn:aws:ec2:ap-southeast-1::image/*",
                "arn:aws:ec2:ap-southeast-1::snapshot/*",
                "arn:aws:ec2:ap-southeast-1:*:security-group/*",
                "arn:aws:ec2:ap-southeast-1:*:subnet/*",
                "arn:aws:ec2:ap-southeast-1:*:capacity-reservation/*",
                "arn:aws:ec2:ap-southeast-1:*:placement-group/*"
              ],
              "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet"
              ]
            },
            {
              "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
              "Effect": "Allow",
              "Resource": "arn:aws:ec2:ap-southeast-1:*:launch-template/*",
              "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/nextcloud": "owned"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.sh/nodepool": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedEC2InstanceActionsWithTags",
              "Effect": "Allow",
              "Resource": [
                "arn:aws:ec2:ap-southeast-1:*:fleet/*",
                "arn:aws:ec2:ap-southeast-1:*:instance/*",
                "arn:aws:ec2:ap-southeast-1:*:volume/*",
                "arn:aws:ec2:ap-southeast-1:*:network-interface/*",
                "arn:aws:ec2:ap-southeast-1:*:launch-template/*",
                "arn:aws:ec2:ap-southeast-1:*:spot-instances-request/*"
              ],
              "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet",
                "ec2:CreateLaunchTemplate"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:RequestTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:RequestTag/eks:eks-cluster-name": "nextcloud"
                },
                "StringLike": {
                  "aws:RequestTag/karpenter.sh/nodepool": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedResourceCreationTagging",
              "Effect": "Allow",
              "Resource": [
                "arn:aws:ec2:ap-southeast-1:*:fleet/*",
                "arn:aws:ec2:ap-southeast-1:*:instance/*",
                "arn:aws:ec2:ap-southeast-1:*:volume/*",
                "arn:aws:ec2:ap-southeast-1:*:network-interface/*",
                "arn:aws:ec2:ap-southeast-1:*:launch-template/*",
                "arn:aws:ec2:ap-southeast-1:*:spot-instances-request/*"
              ],
              "Action": "ec2:CreateTags",
              "Condition": {
                "StringEquals": {
                  "aws:RequestTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:RequestTag/eks:eks-cluster-name": "nextcloud",
                  "ec2:CreateAction": [
                    "RunInstances",
                    "CreateFleet",
                    "CreateLaunchTemplate"
                  ]
                },
                "StringLike": {
                  "aws:RequestTag/karpenter.sh/nodepool": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedResourceTagging",
              "Effect": "Allow",
              "Resource": "arn:aws:ec2:ap-southeast-1:*:instance/*",
              "Action": "ec2:CreateTags",
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/nextcloud": "owned"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.sh/nodepool": "*"
                },
                "StringEqualsIfExists": {
                  "aws:RequestTag/eks:eks-cluster-name": "nextcloud"
                },
                "ForAllValues:StringEquals": {
                  "aws:TagKeys": [
                    "eks:eks-cluster-name",
                    "karpenter.sh/nodeclaim",
                    "Name"
                  ]
                }
              }
            },
            {
              "Sid": "AllowScopedDeletion",
              "Effect": "Allow",
              "Resource": [
                "arn:aws:ec2:ap-southeast-1:*:instance/*",
                "arn:aws:ec2:ap-southeast-1:*:launch-template/*"
              ],
              "Action": [
                "ec2:TerminateInstances",
                "ec2:DeleteLaunchTemplate"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/nextcloud": "owned"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.sh/nodepool": "*"
                }
              }
            },
            {
              "Sid": "AllowPassingInstanceRole",
              "Effect": "Allow",
              "Resource": "arn:aws:iam::463884819678:role/KarpenterNodeRole-nextcloud",
              "Action": "iam:PassRole",
              "Condition": {
                "StringEquals": {
                  "iam:PassedToService": [
                    "ec2.amazonaws.com",
                    "ec2.amazonaws.com.cn"
                  ]
                }
              }
            },
            {
              "Sid": "AllowScopedInstanceProfileCreationActions",
              "Effect": "Allow",
              "Resource": "arn:aws:iam::463884819678:instance-profile/*",
              "Action": [
                "iam:CreateInstanceProfile"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:RequestTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:RequestTag/eks:eks-cluster-name": "nextcloud",
                  "aws:RequestTag/topology.kubernetes.io/region": "ap-southeast-1"
                },
                "StringLike": {
                  "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedInstanceProfileTagActions",
              "Effect": "Allow",
              "Resource": "arn:aws:iam::463884819678:instance-profile/*",
              "Action": [
                "iam:TagInstanceProfile"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:ResourceTag/topology.kubernetes.io/region": "ap-southeast-1",
                  "aws:RequestTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:RequestTag/eks:eks-cluster-name": "nextcloud",
                  "aws:RequestTag/topology.kubernetes.io/region": "ap-southeast-1"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
                  "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedInstanceProfileActions",
              "Effect": "Allow",
              "Resource": "arn:aws:iam::463884819678:instance-profile/*",
              "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/nextcloud": "owned",
                  "aws:ResourceTag/topology.kubernetes.io/region": "ap-southeast-1"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
              }
            },
            {
              "Sid": "AllowAPIServerEndpointDiscovery",
              "Effect": "Allow",
              "Resource": "arn:aws:eks:ap-southeast-1:463884819678:cluster/nextcloud",
              "Action": "eks:DescribeCluster"
            },
            {
              "Sid": "AllowInterruptionQueueActions",
              "Effect": "Allow",
              "Resource": "arn:aws:sqs:ap-southeast-1:463884819678:nextcloud",
              "Action": [
                "sqs:DeleteMessage",
                "sqs:GetQueueUrl",
                "sqs:ReceiveMessage"
              ]
            },
            {
              "Sid": "AllowZonalShiftStatusReadOnly",
              "Effect": "Allow",
              "Resource": "*",
              "Action": [
                "arc-zonal-shift:GetManagedResource"
              ],
              "Condition": {
                "StringEquals": {
                  "arc-zonal-shift:ResourceIdentifier": "arn:aws:eks:ap-southeast-1:463884819678:cluster/nextcloud"
                }
              }
            },
            {
              "Sid": "AllowRegionalReadActions",
              "Effect": "Allow",
              "Resource": "*",
              "Action": [
                "ec2:DescribeCapacityReservations",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribePlacementGroups",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:RequestedRegion": "ap-southeast-1"
                }
              }
            },
            {
              "Sid": "AllowSSMReadActions",
              "Effect": "Allow",
              "Resource": "arn:aws:ssm:ap-southeast-1::parameter/aws/service/*",
              "Action": "ssm:GetParameter"
            },
            {
              "Sid": "AllowPricingReadActions",
              "Effect": "Allow",
              "Resource": "*",
              "Action": "pricing:GetProducts"
            },
            {
              "Sid": "AllowUnscopedInstanceProfileListAction",
              "Effect": "Allow",
              "Resource": "*",
              "Action": "iam:ListInstanceProfiles"
            },
            {
              "Sid": "AllowInstanceProfileReadActions",
              "Effect": "Allow",
              "Resource": "arn:aws:iam::463884819678:instance-profile/*",
              "Action": "iam:GetInstanceProfile"
            }
          ]
        }
  )
}







resource "kubernetes_service_account" "karpenter_controller" {
  metadata {
    name      = "karpenter-controller"   
    namespace = var.kube_system_namespace                    
  }
}

resource "aws_eks_pod_identity_association" "karpenter_controller" {
  cluster_name    = var.cluster_name
  namespace       = var.kube_system_namespace   
  service_account = kubernetes_service_account.karpenter_controller.metadata[0].name
  role_arn        = aws_iam_role.karpenter_controller.arn
}




resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-nextcloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
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
  name = "karpenter-node"
  role = aws_iam_role.karpenter_node.name
}

