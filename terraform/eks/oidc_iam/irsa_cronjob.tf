resource "aws_iam_role" "postgres_backup" {
  name = "eks_postgres_backup_role"

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
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:dev:postgres-backup"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "postgres_backup" {
  name = "postgres_backup_policy"
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




resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "postgres-backup"   
    namespace = "dev"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.postgres_backup.arn  
    }
  }
}
