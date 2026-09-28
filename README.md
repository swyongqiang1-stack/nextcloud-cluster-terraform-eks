# Nextcloud on AWS EKS

A personal infrastructure project that brings Nextcloud from a single-server deployment to AWS EKS using Terraform, Kubernetes, and Helm.

The project covers networking, persistent storage, workload identity, ingress, logging, autoscaling, and application backups.

> **Status:** The infrastructure implementation and CI milestone are complete. The GitHub Actions Terraform workflow has passed formatting checks, configuration validation, and Terraform plan. End-to-end deployment, application behavior, and backup restoration still require runtime verification. This repository is not yet production-ready.

## Architecture

The configured traffic path is:

```text
Internet
   |
   v
AWS ALB — HTTPS with ACM
   |
   v
NGINX Ingress Controller
   |
   v
Nextcloud Service
   |
   v
Nextcloud Pods
   |
   +── EFS — shared application files and user data
   |
   +── PostgreSQL — EBS gp3 persistent storage
   |
   +── Redis — cache and transactional file locking
```

Supporting components:

- **Secrets:** AWS Secrets Manager → External Secrets Operator → Kubernetes Secrets.
- **AWS access:** EKS Pod Identity associates Kubernetes ServiceAccounts with IAM roles.
- **Kubernetes access:** RBAC grants permissions to controllers and the backup ServiceAccount.
- **Logging:** Fluent Bit → CloudWatch Logs.
- **Application scaling:** CPU-based HPA.
- **Node provisioning:** Karpenter with NodePool and EC2NodeClass manifests.
- **Backups:** Nextcloud directories and PostgreSQL dumps → Amazon S3.
- **CI:** Terraform checks and backup image builds through GitHub Actions.

Prometheus and Grafana are not currently deployed by the repository.

## Technology Stack

| Area | Technologies |
|---|---|
| Infrastructure as code | Terraform |
| AWS networking | VPC, public/private subnets, route tables, Internet Gateway, NAT Gateway, Elastic IP |
| Cluster and compute | Amazon EKS, EC2, managed node groups, dedicated database node group |
| Application deployment | Helm, Nextcloud, PostgreSQL, Redis |
| Persistent storage | EFS, EBS gp3, EFS CSI Driver, EBS CSI Driver, StorageClass, PVC |
| Ingress and HTTPS | AWS Load Balancer Controller, ALB, NGINX Ingress Controller, ACM |
| Identity and secrets | IAM, EKS Pod Identity, EKS access entries, AWS Secrets Manager, External Secrets Operator |
| Scheduling | nodeSelector, taints/tolerations, pod anti-affinity, PriorityClass |
| Resource and network controls | NetworkPolicy, ResourceQuota, LimitRange |
| Scaling | HPA, Karpenter |
| Logging | Fluent Bit, CloudWatch Logs |
| Backup tooling | Kubernetes CronJob, ConfigMap, kubectl, pg_dump, tar, gzip, AWS CLI, S3 |
| Image delivery and CI | Docker, Amazon ECR, GitHub Actions, GitHub OIDC |

An EKS OIDC provider is also defined, but the configured workload IAM associations primarily use **EKS Pod Identity**, rather than IRSA.

## Storage and Scheduling

Nextcloud is configured with two replicas and required pod anti-affinity to place them on different nodes.

Two EFS-backed `ReadWriteMany` PVCs are configured:

- A main volume for Nextcloud application storage.
- A separate volume for Nextcloud user data.

PostgreSQL uses EBS gp3 storage. A dedicated database node group, combined with node selectors and taints/tolerations, separates database workloads from general application workloads.

Dedicated nodes provide scheduling isolation; they do not make PostgreSQL highly available. Multi-node application behavior and storage recovery still require runtime testing.

## Backup Design

The backup script is stored in a Kubernetes ConfigMap and executed by a CronJob using a dedicated ServiceAccount.

The current script implements this sequence:

1. Select a running Nextcloud Pod.
2. Check that Nextcloud is installed and is not already in maintenance mode.
3. Enable maintenance mode using `occ`.
4. Archive `config`, `custom_apps`, `themes`, and `data` through `kubectl exec`, then upload the archive to S3.
5. Export PostgreSQL using `pg_dump`, compress the output, and upload it to the same backup prefix.
6. Disable maintenance mode.
7. Write a `COMPLETE` marker after successful execution.

```text
s3://<backup-bucket>/nextcloud/<backup-id>/
├── nextcloud-files.tar.gz
├── database.sql.gz
└── COMPLETE
```

The script attempts to disable maintenance mode when an ordinary command fails. It does not automatically stop application replicas or drain existing requests and background jobs. Backup consistency therefore depends on preventing writes during the backup window.

Pod loss or forced termination may require manual recovery. A `COMPLETE` marker indicates successful script execution, not a verified restore.

Before running the backup CronJob, ensure that its image URI points to a successfully built image in ECR.

## Repository Layout

```text
.
├── bootstrap/                  # GitHub OIDC, CI IAM role and bootstrap backend
├── terraform/
│   ├── modules/
│   │   └── vpc/                # VPC, subnets, routes and NAT
│   ├── eks/
│   │   ├── aws_*.tf            # AWS resources, EKS, node groups and access
│   │   ├── helm_*.tf           # Helm releases and ingress resources
│   │   ├── pod_identity_*.tf   # Workload IAM and ServiceAccounts
│   │   ├── eks_*.tf            # Storage, policies, scaling and backups
│   │   ├── tf_*.tf             # Variables, locals, data and backend
│   │   ├── values_*.yaml       # Helm values
│   │   ├── main.tf             # Providers and VPC module
│   │   └── oidc.tf             # EKS OIDC provider
│   └── freamwork.md
├── k8s/
│   ├── infrastructure/
│   │   ├── secretstore.yaml
│   │   └── karpenter/          # NodePool and EC2NodeClass
│   └── nextcloud/
│       └── secret/             # ExternalSecret manifests
├── images/
│   └── postgres-backup/        # Backup image Dockerfile
├── .github/
│   └── workflows/              # Terraform and image-build CI
└── README.md
```

The manifests under `k8s/` are separate from the Terraform configuration and require an explicit deployment step after their controllers and CRDs are available.

## CI and Image Delivery

Two GitHub Actions workflows are defined:

| Workflow | Purpose |
|---|---|
| Terraform CI | Run formatting checks, initialize providers, validate configuration, and generate a plan |
| Backup image build | Build the backup image and push it to Amazon ECR |

The Terraform CI workflow has successfully completed:

- `terraform fmt -check -recursive`
- Terraform initialization
- `terraform validate`
- `terraform plan`

A successful plan confirms that Terraform can generate the proposed infrastructure changes for the configured environment. It does not create those resources or verify application behavior.

The image workflow is triggered by changes under `images/postgres-backup/` pushed to `main`. Images are tagged with the triggering Git commit SHA.

After a successful build, the resulting ECR image URI must be configured for the backup CronJob. The current workflows do not automatically apply Terraform or update the CronJob image.

## Current Progress

| Area | Current state |
|---|---|
| Infrastructure implementation | Implementation milestone complete |
| Terraform formatting checks | Passed in GitHub Actions |
| Terraform configuration validation | Passed in GitHub Actions |
| Terraform plan | Successfully generated in GitHub Actions |
| VPC, EKS and node groups | Configuration included in the plan; deployment verification pending |
| Nextcloud, PostgreSQL and Redis | Helm configuration present; runtime integration testing pending |
| EFS and EBS storage | Resource and CSI configurations present; mounting and persistence tests pending |
| ALB, NGINX and HTTPS | Ingress configuration present; end-to-end access testing pending |
| Pod Identity and secrets | IAM associations and secret manifests present; runtime verification pending |
| Logging | Fluent Bit and CloudWatch configuration present; delivery verification pending |
| HPA and Karpenter | Scaling configurations present; metrics availability and provisioning tests pending |
| Backups | Directory and database backup script present; image readiness and execution verification pending |
| Restore and resilience | Restore, failure recovery, and upgrade/rollback tests pending |

## Deployment Preparation

Required tools:

- Terraform
- AWS CLI
- kubectl
- Helm

Before deployment:

1. Confirm AWS credentials and access to the S3 Terraform state backend.
2. Review environment-specific values, including network ranges, account references, domain, and ACM certificate.
3. Prepare the required Secrets Manager entries.
4. Confirm the ECR repository and GitHub Actions authentication configuration.
5. Build the backup image and configure the resulting image URI.
6. Review a fresh Terraform plan for the exact code and environment being deployed, including any proposed deletions or replacements.

Terraform plan has passed in CI. The next milestone is controlled deployment and runtime verification.

The deployment workflow should not yet be treated as an unattended installation process. Kubernetes manifests, application readiness, and recovery procedures still require verification.

## Validation Goals

Completed:

- [x] Terraform formatting checks pass in CI.
- [x] Terraform configuration validation passes in CI.
- [x] Terraform plan completes successfully in CI.

Pending runtime verification:

- [ ] Infrastructure and applications can be deployed through documented, repeatable steps.
- [ ] HTTPS access, login, upload, and download work.
- [ ] Application and database data survive Pod recreation.
- [ ] Network policies allow required traffic and block unintended access.
- [ ] Workloads can access the required AWS services through Pod Identity.
- [ ] Logs reach CloudWatch.
- [ ] HPA and Karpenter scale workloads and nodes as expected.
- [ ] A backup can restore a working Nextcloud instance, including files, configuration, and database.
- [ ] Multi-node operation, controlled failures, and upgrade/rollback procedures have been tested.

## Cost and Cleanup

This project creates chargeable AWS resources when deployed, including EKS, EC2 instances, NAT Gateways, load balancers, EFS, EBS, S3, and CloudWatch Logs.

When removing the environment, review persistent volumes, retained EBS volumes, EFS data, backups, and Terraform state separately. Some resources may remain after workload deletion, while others may be deleted by Terraform. Confirm data retention requirements before cleanup.