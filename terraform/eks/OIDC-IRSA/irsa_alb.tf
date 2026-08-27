resource "aws_iam_openid_connect_provider" "cluster" {
  url = "https://oidc.eks.ap-southeast-1.amazonaws.com/id/留空"
#aws eks describe-cluster --name 集群名 --query "cluster.identity.oidc.issuer"
#取上面的 id 复制进去
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}


resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "eks_lb_controller_role"

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
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "oidc.eks.ap-southeast-1.amazonaws.com/id/你的集群OIDC-ID:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/iam_policy.json")   
}

#https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
#权限文件放到当前目录。

    #角色和权限策略挂在attachment
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn   
}


resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"   
    namespace = "kube-system"                     
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn  
    }
  }
}