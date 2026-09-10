resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.5.0"
  namespace = "kube-system"
  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]

  set {
    name = "clusterName"
    value = "nextcloud"
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

#警告，先创建 serviceaccount，再跑这个。
#先去跑 irsa_alb.tf
