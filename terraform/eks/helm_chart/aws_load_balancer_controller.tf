resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.5.0"
  namespace = "kube-system"
  depends_on = [ 
    modules.oidc_iam,
    aws_eks_cluster.nextcloud
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


