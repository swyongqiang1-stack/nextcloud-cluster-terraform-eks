resource "aws_iam_role" "external_secrets" {
  name = "eks_external_secrets_role"

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
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:monitoring:external-secrets"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "external_secrets" {
  name = "external_secrets_policy"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}




resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"   
    namespace = "external-secrets"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn  
    }
  }
}
