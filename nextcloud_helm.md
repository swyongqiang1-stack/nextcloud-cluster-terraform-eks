Internet
   │
ingress-nginx
   │
Nextcloud (Helm)
   ├── App PVC ──────── EBS gp3
   ├── Data PVC ─────── EBS gp3
   │
   └── PostgreSQL
          │
          ├── Dedicated DB Node Group
          │   ├── Label / nodeSelector
          │   └── Taint / Toleration
          │
          └── DB PVC ── EBS gp3

AWS Secrets Manager
        │
       ESO
        │
 Kubernetes Secrets
        │
   ┌────┴────┐
Nextcloud  PostgreSQL




- PostgreSQL dependency/subchart
- 数据库专用节点
- 调度隔离
- EBS 持久化
- Nextcloud 与 PostgreSQL 分离存储
- AWS Secrets Manager
- ESO
- Ingress
- Terraform 管理 Helm release
