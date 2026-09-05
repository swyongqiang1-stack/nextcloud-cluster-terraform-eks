resource "aws_iam_role" "fluent_bit" {
  name = "eks_fluent_bit_role"

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
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:dev:fluent-bit"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fluent_bit" {
  name = "fluent_bit_policy"
  role = aws_iam_role.fluent_bit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

#https://docs.fluentbit.io/manual/data-pipeline/outputs/cloudwatch  action come from this
#so these is my self check and write,no use ai



resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "fluent-bit"   
    namespace = "dev"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn  
    }
  }
}
