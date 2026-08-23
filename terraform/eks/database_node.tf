resource "aws_eks_node_group" "database" {
  cluster_name    = aws_eks_cluster.e_cm.name
  node_group_name = "database"
  node_role_arn   = aws_iam_role.database.arn
  subnet_ids      = module.vpc.private_subnet_ids
  labels = {
    workload = "database"
  }
  
taint {
  key    = "workload"
  value  = "database"
  effect = "NO_SCHEDULE"
}


  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 3
  }

  update_config {
    max_unavailable = 3
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.database-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.database-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.database-AmazonEC2ContainerRegistryReadOnly,
  ]
}



resource "aws_iam_role" "database" {
  name = "eks-node-group-database"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "database-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.database.name
}

resource "aws_iam_role_policy_attachment" "database-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.database.name
}

resource "aws_iam_role_policy_attachment" "database-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.database.name
}