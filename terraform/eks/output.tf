output "ebs_role_arn" {
  value = aws_iam_role.nextcloud_ebs.arn
}

output "efs_role_arn" {
  value = aws_iam_role.nextcloud_efs.arn
}

output "karpenter_node_arn" {
  value = aws_iam_role.karpenter_node.arn
}

output "karpenter_controller_sa" {
  value = kubernetes_service_account.karpenter_controller.metadata[0].name
}

output "eso_sa" {
  value = kubernetes_service_account.external_secrets.metadata[0].name
}

output "fluent_bit_sa" {
  value = kubernetes_service_account.fluent_bit.metadata[0].name
}

output "alb_sa" {
  value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
}

output "cronjob_postgres_backup_sa" {
  value = kubernetes_service_account.postgres_backup.metadata[0].name
}