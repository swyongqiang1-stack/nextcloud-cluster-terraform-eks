resource "aws_iam_role" "fluent_bit" {
  name = "eks-fluent-bit-role"


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


resource "aws_iam_role_policy" "fluent_bit" {
  name = "fluent-bit-policy"
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

  }
}


resource "aws_eks_pod_identity_association" "fluent_bit" {
  cluster_name    = aws_eks_cluster.nextcloud.name
  namespace       = "dev"
  service_account = "fluent-bit"
  role_arn        = aws_iam_role.fluent_bit.arn
}
