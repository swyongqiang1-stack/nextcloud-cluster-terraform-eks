output "ebs_role_arn" {
  value = aws_iam_role.nextcloud_ebs.arn
}

output "efs_role_arn" {
  value = aws_iam_role.nextcloud_efs.arn
}

output "karpenter_node_arn" {
  value = aws_iam_role.karpenter_node.arn
}