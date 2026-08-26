## Nextcloud Architecture

```text
Internet
   │
   ▼
ingress-nginx
   │
   ▼
Nextcloud (Helm)
   ├── App PVC ─────────── EBS gp3
   ├── Data PVC ────────── EBS gp3
   │
   └── PostgreSQL
          │
          ├── Dedicated DB Node Group
          │      ├── Label / nodeSelector
          │      └── Taint / Toleration
          │
          └── DB PVC ───── EBS gp3


AWS Secrets Manager
        │
        ▼
       ESO
        │
        ▼
Kubernetes Secrets
        │
   ┌────┴────┐
   ▼         ▼
Nextcloud  PostgreSQL
```

## Key Design Decisions

- PostgreSQL dependency/subchart
- Dedicated database node group
- Scheduling isolation with labels, nodeSelector, taints and tolerations
- EBS-backed persistent storage
- Separate Nextcloud application, data and PostgreSQL storage
- AWS Secrets Manager for credentials
- External Secrets Operator (ESO)
- ingress-nginx integration
- Terraform-managed Helm release
