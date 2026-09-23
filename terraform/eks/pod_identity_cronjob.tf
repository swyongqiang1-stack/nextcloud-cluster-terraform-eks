resource "aws_iam_role" "postgres_backup" {
  name = "eks-postgres-backup-role"

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

resource "aws_iam_role_policy" "postgres_backup" {
  name = "postgres-backup-policy"
  role = aws_iam_role.postgres_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = local.backup_resource
      }
    ]
  })
}



resource "kubernetes_service_account" "postgres_backup" {
  metadata {
    name      = "postgres-backup"
    namespace = local.namespace.nextcloud_namespace
  }
}

resource "kubernetes_role_v1" "backup_exec" {
  metadata {
    name      = "backup-exec"
    namespace = local.namespace.nextcloud_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_role_binding_v1" "backup_exec" {
  metadata {
    name      = "backup-exec"
    namespace = local.namespace.nextcloud_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.backup_exec.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "postgres-backup"
    namespace = local.namespace.nextcloud_namespace
  }
}



resource "aws_eks_pod_identity_association" "postgres_backup" {
  cluster_name    = local.cluster_name
  namespace       = local.namespace.nextcloud_namespace
  service_account = kubernetes_service_account.postgres_backup.metadata[0].name
  role_arn        = aws_iam_role.postgres_backup.arn
}

