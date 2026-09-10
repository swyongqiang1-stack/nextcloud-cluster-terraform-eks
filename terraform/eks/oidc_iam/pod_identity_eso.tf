resource "aws_iam_role" "external_secrets" {
  name = "eks-external-secrets-role"

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


resource "aws_iam_role_policy" "external_secrets" {
  name = "external-secrets-policy"
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
    name      = "external-secrets-sa"   
    namespace = "external-secrets"                     
  }
}


resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = aws_eks_cluster.nextcloud.name
  namespace       = "external-secrets"
  service_account = "external-secrets-sa"
  role_arn        = aws_iam_role.external_secrets.arn
}


