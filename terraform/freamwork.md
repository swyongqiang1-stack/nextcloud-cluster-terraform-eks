terraform/
├── infra/
│   ├── main.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── node.tf
│   ├── database_node.tf
│   ├── addon.tf
│   ├── access.tf
│   ├── iam.tf
│   └── backend.tf
│
└── platform/
    ├── main.tf
    ├── providers.tf
    ├── namespace.tf
    ├── irsa_alb.tf
    ├── irsa_eso.tf
    ├── ingress_nginx.tf
    ├── aws_load_balancer_controller.tf
    ├── eso.tf
    ├── nextcloud.tf
    ├── order_api.tf
    ├── product_api.tf
    ├── user_api.tf
    ├── quota.tf
    └── backend.tf