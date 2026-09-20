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
    namespace = local.namespace.nextcloud_namespace
  }
}


resource "aws_eks_pod_identity_association" "postgres_backup" {
  cluster_name    = local.cluster_name
  namespace       = local.namespace.nextcloud_namespace
  service_account = kubernetes_service_account.postgres_backup.metadata[0].name
  role_arn        = aws_iam_role.postgres_backup.arn
}

