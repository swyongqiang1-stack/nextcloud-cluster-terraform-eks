# nextcloud-cluster-terraform-eks

A reproducible reference implementation for deploying a small highly available Nextcloud cluster on AWS EKS using Terraform and Helm.

This project started from a simple question: how difficult is it to move a traditional single-server Nextcloud deployment into Kubernetes?

At first, I expected the main task to be creating a Deployment with multiple replicas. In practice, a clustered Nextcloud setup requires several infrastructure layers to work together: shared storage, PostgreSQL persistence, Redis locking, ingress, AWS IAM, CSI drivers, secret management, and Kubernetes scheduling.

The goal of this repository is to provide a practical and understandable Nextcloud-on-EKS implementation that can be studied, reproduced, and adapted.

## Architecture

```text
                         Internet
                            |
                            v
                         AWS ALB
                            |
                            v
                     ingress-nginx
                            |
                            v
                +-----------------------+
                |   Nextcloud x 2-3     |
                |      (Helm)           |
                +-----------+-----------+
                            |
             +--------------+--------------+
             |                             |
             v                             v
        Amazon EFS                       Redis
     shared Nextcloud             cache / file locking
         storage
             |
             |
             +-----------------------------+
                                           |
                                           v
                                  PostgreSQL StatefulSet
                                           |
                                           v
                                        EBS gp3
```

AWS secret flow:

```text
AWS Secrets Manager
        |
        v
External Secrets Operator
        |
        v
Kubernetes Secret
        |
        +--> Nextcloud
        |
        +--> PostgreSQL
```

Infrastructure provisioning:

```text
Terraform
   |
   +-- VPC / Subnets / NAT
   +-- EKS
   +-- Managed Node Groups
   +-- Dedicated Database Node Group
   +-- EBS CSI
   +-- EFS CSI
   +-- IAM / OIDC / IRSA
   +-- AWS Load Balancer Controller
   +-- Helm Releases
```

## Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Cloud | AWS |
| Kubernetes | Amazon EKS |
| Application Deployment | Helm |
| Application | Nextcloud |
| Shared Storage | Amazon EFS + EFS CSI |
| Database | PostgreSQL StatefulSet |
| Database Storage | Amazon EBS gp3 + EBS CSI |
| Cache / File Locking | Redis |
| External Load Balancer | AWS ALB |
| Kubernetes Ingress | ingress-nginx |
| Secret Management | AWS Secrets Manager + External Secrets Operator |
| AWS Workload Identity | IAM / OIDC / IRSA |
| Scheduling Isolation | Taints, Tolerations, nodeSelector / node affinity |
| Observability | Prometheus / Grafana |

## Key Design Decisions

### Shared storage for Nextcloud

Multiple Nextcloud replicas must be able to access the same persistent application data.

Amazon EFS is used as shared storage because it supports ReadWriteMany access across multiple Kubernetes nodes.

```text
Nextcloud Pod A ----+
Nextcloud Pod B ----+---- Amazon EFS
Nextcloud Pod C ----+
```

This differs from EBS, which is better suited to single-writer block-storage workloads such as PostgreSQL.

### PostgreSQL uses EBS gp3

PostgreSQL runs as a Kubernetes StatefulSet and stores its database files on an EBS gp3 volume.

```text
PostgreSQL StatefulSet
        |
        v
       PVC
        |
        v
     EBS gp3
```

The database uses block storage rather than EFS because PostgreSQL benefits from low-latency block I/O and does not require shared RWX storage.

### Dedicated database node group

PostgreSQL runs on a dedicated EKS managed node group.

Scheduling isolation is implemented using:

- Node labels
- Taints
- Tolerations
- nodeSelector / node affinity

This prevents database workloads from competing directly with general application workloads.

### Redis for Nextcloud locking and caching

Redis is used for Nextcloud transactional file locking and caching.

In a multi-replica Nextcloud environment, all replicas must use the same Redis service so that file-lock state remains consistent across application pods.

### No long-lived AWS credentials inside Kubernetes

AWS Secrets Manager stores sensitive credentials.

External Secrets Operator retrieves them using IRSA and generates Kubernetes Secrets.

```text
Secrets Manager
      |
      v
     ESO
      |
      v
Kubernetes Secret
```

No static AWS access keys are stored in the repository or application manifests.

### AWS permissions through IRSA

AWS-integrated Kubernetes components receive workload-specific IAM permissions using IAM Roles for Service Accounts.

Separate IAM roles can be used for components such as:

- AWS Load Balancer Controller
- External Secrets Operator
- EFS CSI Driver

This avoids granting broad AWS permissions to the EKS node role.

### ALB and ingress-nginx

AWS Load Balancer Controller provisions the external Application Load Balancer.

Traffic is forwarded into ingress-nginx, which handles Kubernetes-level routing toward Nextcloud.

```text
Internet
   |
   v
AWS ALB
   |
   v
ingress-nginx
   |
   v
Nextcloud
```

## Kubernetes Resources

| Resource | Purpose |
|---|---|
| Deployment | Nextcloud application replicas |
| StatefulSet | PostgreSQL and Redis where required |
| Service | Internal application and database connectivity |
| Ingress | HTTP/HTTPS routing |
| StorageClass | EBS / EFS dynamic storage provisioning |
| PersistentVolumeClaim | Persistent application and database storage |
| Secret | Credentials generated by ESO |
| ResourceQuota | Namespace resource limits |
| LimitRange | Default container resource limits |
| PodDisruptionBudget | Protect application availability during voluntary disruption |
| Pod Anti-Affinity | Spread Nextcloud replicas across nodes |
| Taint / Toleration | Database node isolation |
| nodeSelector / Affinity | Explicit database scheduling |

## Repository Structure

```text
.
├── terraform/
│   ├── modules/
│   │   └── vpc/
│   │
│   └── eks/
│       ├── OIDC-IRSA/
│       │   ├── iam_policy.json
│       │   ├── irsa_alb.tf
│       │   └── irsa_eso.tf
│       │
│       ├── helm/
│       │   ├── aws_load_balancer_controller.tf
│       │   ├── eso.tf
│       │   ├── ingress-nginx.tf
│       │   └── nextcloud_chart.tf
│       │
│       ├── values/
│       │   ├── ingress_nginx.yaml
│       │   └── nextcloud.yaml
│       │
│       ├── eks.tf
│       ├── node.tf
│       ├── database_node.tf
│       ├── StorageClass.tf
│       ├── namespace.tf
│       ├── quota.tf
│       ├── addon.tf
│       ├── access.tf
│       ├── state_backend.tf
│       └── variables.tf
│
├── k8s/
│   └── nextcloud/
│       ├── secretstore.yaml
│       └── externalsecret.yaml
│
├── README.md
└── nextcloud_helm.md
```

## Current Scope

The project focuses on a small Nextcloud cluster rather than a large enterprise platform.

Core scope:

- Terraform-managed AWS infrastructure
- Amazon EKS
- Multi-AZ networking
- Managed Node Groups
- Dedicated PostgreSQL node group
- Nextcloud Helm deployment
- Multiple Nextcloud replicas
- Amazon EFS shared storage
- PostgreSQL StatefulSet with EBS gp3
- Redis caching and file locking
- AWS Load Balancer Controller
- ingress-nginx
- AWS Secrets Manager
- External Secrets Operator
- IAM / IRSA
- Basic availability controls
- Basic monitoring and failure testing

The project intentionally avoids unnecessary platform complexity such as service mesh, multi-region deployment, or large-scale database clustering.

## Project Status

| Phase | Scope | Status |
|---|---|---|
| 1 | VPC, EKS, Managed Node Groups | 🚧 |
| 2 | Dedicated database node group | 🚧 |
| 3 | EBS CSI and PostgreSQL persistence | 🚧 |
| 4 | AWS Load Balancer Controller | 🚧 |
| 5 | ingress-nginx | 🚧 |
| 6 | External Secrets Operator + IRSA | 🚧 |
| 7 | Nextcloud Helm deployment | 🚧 |
| 8 | Amazon EFS + EFS CSI | Planned |
| 9 | Nextcloud multiple replicas | Planned |
| 10 | Redis caching and file locking | Planned |
| 11 | PDB and Pod Anti-Affinity | Planned |
| 12 | Prometheus / Grafana monitoring | Planned |
| 13 | Pod / Node failure testing | Planned |
| 14 | Backup / restore validation | Planned |

## Getting Started

### Prerequisites

- AWS account
- Terraform
- AWS CLI
- kubectl
- Helm

### Provision Infrastructure

```bash
cd terraform/eks

terraform init
terraform plan
terraform apply
```

### Configure kubectl

```bash
aws eks update-kubeconfig \
  --region <aws-region> \
  --name <cluster-name>
```

### Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl get ingress -A
kubectl get pvc -A
```

## Validation Goals

A deployment is considered successful when:

1. Multiple Nextcloud replicas are running.
2. All replicas access the same EFS-backed data.
3. PostgreSQL survives Pod recreation with its EBS volume intact.
4. Redis provides shared file locking and caching.
5. External traffic reaches Nextcloud through ALB and ingress-nginx.
6. Credentials are synchronized from AWS Secrets Manager through ESO.
7. Removing one Nextcloud Pod does not make the service unavailable.
8. Nextcloud replicas are distributed across Kubernetes nodes.

## Cost Note

This project creates chargeable AWS resources including:

- EKS control plane
- EC2 worker nodes
- NAT Gateway
- Application Load Balancer
- EBS volumes
- EFS storage

AWS Budget alerts are strongly recommended before deployment.

## Project Goal

The goal of this repository is not to build a large enterprise Nextcloud platform.

It is to provide a small, reproducible, and technically understandable Nextcloud cluster on AWS EKS while demonstrating the infrastructure components required to run a stateful application correctly on Kubernetes.