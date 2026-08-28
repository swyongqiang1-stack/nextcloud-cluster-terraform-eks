## Nextcloud Architecture

```text
Internet
   |
   v
ingress-nginx
   |
   v
Nextcloud (Helm, multiple replicas)
   |
   +-- Shared Persistent Storage --> Amazon EFS
   |
   +-- PostgreSQL
          |
          +-- Dedicated DB Node Group
          |      +-- Label / nodeSelector
          |      +-- Taint / Toleration
          |
          +-- DB PVC --> EBS gp3


AWS Secrets Manager
        |
        v
External Secrets Operator (ESO)
        |
        v
Kubernetes Secrets
        |
        +--> Nextcloud
        |
        +--> PostgreSQL
```

## Key Design Decisions

- Nextcloud deployed via Helm with multiple replicas
- Shared Nextcloud persistent storage backed by Amazon EFS
- PostgreSQL dependency/subchart
- PostgreSQL persistent volume backed by EBS gp3
- Dedicated database node group
- Scheduling isolation with labels, nodeSelector, taints and tolerations
- AWS Secrets Manager for credentials
- External Secrets Operator (ESO)
- ingress-nginx integration
- Terraform-managed Helm release