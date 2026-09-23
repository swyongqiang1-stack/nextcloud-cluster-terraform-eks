locals {
  namespace = {
    nextcloud_namespace        = kubernetes_namespace.nextcloud.metadata[0].name
    ingress_nginx_namespace    = kubernetes_namespace.ingress-nginx.metadata[0].name
    kube_system_namespace      = data.kubernetes_namespace.kube_system.metadata[0].name
    external_secrets_namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }
}


locals {
  cluster_name = aws_eks_cluster.nextcloud.name
  domain_name  = "www.erben.cn"
  iam_arn      = "arn:aws:acm:ap-southeast-1:463884819678:certificate/1880b9bc-3df9-416c-bc43-97e6a8851050"
  image        = "<你的 ECR 地址>/postgres-backup:<镜像标签>"
  backup_bucket = "elden-state-bucket"
  backup_resource = "arn:aws:s3:::elden-state-bucket/nextcloud/database_backup/*"
  backup_prefix = "nextcloud/database_backup"
  secret_resource = "arn:aws:s3:::elden-state-bucket"
}

