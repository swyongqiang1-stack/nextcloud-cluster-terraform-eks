resource "aws_iam_openid_connect_provider" "cluster" {
  url = "https://oidc.eks.ap-southeast-1.amazonaws.com/id/留空"
#aws eks describe-cluster --name 集群名 --query "cluster.identity.oidc.issuer"
#取上面的 id 复制进去
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}