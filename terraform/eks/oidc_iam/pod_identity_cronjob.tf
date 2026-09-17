resource "aws_iam_role" "postgres_backup" {
  name = "eks-postgres-backup-role"

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

resource "aws_iam_role_policy" "postgres_backup" {
  name = "postgres-backup-policy"
  role = aws_iam_role.postgres_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "*"
      }
    ]
  })
}



resource "kubernetes_service_account" "postgres_backup" {
  metadata {
    name      = "postgres-backup"   
    namespace = "nextcloud"                     
  }
}


resource "aws_eks_pod_identity_association" "postgres_backup" {
  cluster_name    = var.cluster_name
  namespace       = "nextcloud"
  service_account = "postgres-backup"
  role_arn        = aws_iam_role.postgres_backup.arn
}

