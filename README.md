# nextcloud-cluster-terraform-eks

A hands-on infrastructure project for deploying and operating a small Nextcloud platform on AWS EKS using Terraform, Kubernetes, and Helm.

This repository is also used as a cloud-native engineering lab. New Kubernetes and AWS components are introduced gradually, then integrated, tested, reviewed, and refined as the architecture evolves.

The main goal is not simply to make Nextcloud run on Kubernetes, but to understand how infrastructure, storage, networking, IAM, scheduling, observability, backup, and application lifecycle interact in a real system.

---

## Project Background

This project started from a simple question:

> How difficult is it to move a traditional single-server Nextcloud deployment into Kubernetes?

At first, the main task appeared to be deploying several Nextcloud replicas.

In practice, a stateful application such as Nextcloud requires multiple infrastructure layers to work together:

- AWS networking
- Amazon EKS
- Kubernetes scheduling
- persistent storage
- PostgreSQL
- Redis
- ingress and load balancing
- IAM and workload identity
- secret management
- autoscaling
- logging and monitoring
- backup and restore
- failure testing

The project is intentionally developed in stages so that each component can be studied, implemented, tested, and later reviewed as part of the complete system.

---

## Architecture

Current high-level architecture:

```text
                         Internet
                            |
                            v
                         AWS ALB
                            |
                            v
                   Nextcloud Service
                            |
                    +-------+-------+
                    |               |
                    v               v
             Nextcloud Pods        Redis
              replicas 2-3       cache / locking
                    |
                    v
               PostgreSQL
                    |
                    v
                 EBS gp3
```

Planned shared-storage architecture for multi-node Nextcloud replicas:

```text
Nextcloud Pod A ----+
Nextcloud Pod B ----+---- Amazon EFS
Nextcloud Pod C ----+
```

Amazon EFS + EFS CSI is planned for shared RWX application data.

The current repository still contains EBS-backed Nextcloud persistence while the shared-storage design is being completed and validated.

---

## Infrastructure Architecture

```text
Terraform
   |
   +-- AWS VPC
   |    |
   |    +-- Public Subnets
   |    +-- Private Subnets
   |    +-- NAT Gateway
   |
   +-- Amazon EKS
   |    |
   |    +-- Managed Node Group
   |    +-- Dedicated Database Node Group
   |    +-- CoreDNS
   |    +-- VPC CNI
   |
   +-- IAM / OIDC / IRSA
   |
   +-- Kubernetes Resources
   |
   +-- Helm Releases
```

The infrastructure is designed to be reproducible through Terraform rather than manually configured through the AWS console.

---

## AWS Workload Identity

AWS-integrated workloads use IAM Roles for Service Accounts instead of long-lived AWS credentials.

```text
EKS OIDC Provider
        |
        +-- AWS Load Balancer Controller
        |
        +-- External Secrets Operator
        |
        +-- Karpenter
        |
        +-- Fluent Bit
        |
        +-- PostgreSQL Backup CronJob
```

Each workload receives its own ServiceAccount and IAM role.

The goal is to avoid granting broad AWS permissions to the EKS worker-node IAM role.

---

## Secret Management

```text
AWS Secrets Manager
        |
        v
External Secrets Operator
        |
        v
Kubernetes Secret
        |
        +-- Nextcloud
        |
        +-- PostgreSQL
        |
        +-- Redis
```

Static AWS access keys are not intended to be stored inside Kubernetes manifests.

External Secrets Operator retrieves application credentials from AWS Secrets Manager using IRSA.

---

## Application Layer

The main application stack contains:

- Nextcloud
- PostgreSQL
- Redis

Nextcloud is deployed through the official Helm Chart.

PostgreSQL is currently deployed inside Kubernetes for learning purposes.

For a real production environment, a managed database service such as Amazon RDS would normally be considered.

---

## Storage Design

### Nextcloud Storage

Multiple Nextcloud replicas require access to shared application data.

The planned design uses:

```text
Nextcloud replicas
        |
        v
Amazon EFS
        |
        v
EFS CSI Driver
        |
        v
RWX PersistentVolume
```

Amazon EFS supports `ReadWriteMany`, allowing application replicas running on different Kubernetes nodes to access the same storage.

This part is still under development and validation.

### PostgreSQL Storage

PostgreSQL uses EBS gp3 block storage:

```text
PostgreSQL Pod
      |
      v
     PVC
      |
      v
  StorageClass
      |
      v
    EBS gp3
```

EBS is suitable for the single-writer database workload used in this lab.

---

## Database Scheduling Isolation

PostgreSQL is assigned to a dedicated database node group.

Scheduling isolation uses:

- Node labels
- Taints
- Tolerations
- nodeSelector
- Node Affinity
- Pod Anti-Affinity
- PriorityClass

Example scheduling model:

```text
General Node Group
   |
   +-- Nextcloud
   +-- Redis
   +-- Controllers

Database Node Group
   |
   +-- PostgreSQL
```

The goal is to reduce resource competition between application workloads and the database workload.

---

## Kubernetes Availability Controls

The project currently experiments with several Kubernetes scheduling and availability mechanisms:

- Horizontal Pod Autoscaler
- Pod Anti-Affinity
- PriorityClass
- ResourceQuota
- LimitRange
- NetworkPolicy
- Taints and Tolerations
- Node Affinity
- PodDisruptionBudget
- Karpenter

These components are added gradually and then tested together because individual Kubernetes resources can behave differently once scheduling, storage, networking, and autoscaling interact.

---

## Autoscaling

### Horizontal Pod Autoscaler

HPA is used to explore application-level scaling based on resource metrics.

```text
Application Load
      |
      v
CPU / Metrics
      |
      v
     HPA
      |
      v
Deployment replicas
```

The HPA configuration is still being validated against the actual Nextcloud namespace and workload behavior.

### Karpenter

Karpenter is being introduced for infrastructure-level node provisioning.

Target workflow:

```text
Pending Pod
    |
    v
Karpenter
    |
    v
NodePool
    |
    v
EC2NodeClass
    |
    v
New EC2 Node
```

The IAM roles, ServiceAccount, Helm deployment, and EC2NodeClass are being developed.

NodePool provisioning and full autoscaling validation are still in progress.

---

## Network Security

The project uses Kubernetes NetworkPolicy to move toward a default-deny network model.

Target communication paths include:

```text
Internet
   |
   v
AWS ALB
   |
   v
Nextcloud
   |
   +-- PostgreSQL : 5432
   |
   +-- Redis : 6379
   |
   +-- DNS
   |
   +-- Required HTTPS endpoints
```

NetworkPolicy rules are reviewed whenever the ingress architecture changes because changing the traffic path can require corresponding security-policy changes.

---

## Pod Security

The project also experiments with Kubernetes Pod Security controls.

Current areas include:

- Pod Security Admission
- securityContext
- runAsNonRoot
- seccompProfile
- capability restrictions
- privilege-escalation restrictions

The objective is to reduce unnecessary container privileges while maintaining application compatibility.

---

## Logging

Fluent Bit is being introduced as the Kubernetes log collector.

Target logging pipeline:

```text
Nextcloud / Container Logs
          |
          v
   /var/log/containers
          |
          v
     Fluent Bit
       DaemonSet
          |
          v
    CloudWatch Logs
```

Fluent Bit uses a dedicated Kubernetes ServiceAccount and IRSA role for CloudWatch permissions.

Current CloudWatch output configuration includes:

```text
Fluent Bit
    |
    v
CloudWatch Log Group
    |
    v
fluent-bit-cloudwatch
```

The Fluent Bit integration is still being validated, including ServiceAccount ownership, namespace behavior, and CloudWatch permissions.

---

## Monitoring

Prometheus and Grafana are used for metrics and platform visibility.

Planned monitoring areas include:

- Kubernetes node metrics
- Pod CPU and memory usage
- application availability
- PostgreSQL metrics
- Kubernetes controller behavior
- HPA activity
- Karpenter activity
- infrastructure failure scenarios

The project uses `kube-prometheus-stack` as the main monitoring stack.

---

## PostgreSQL Backup

A Kubernetes CronJob is being developed for PostgreSQL backup.

Target workflow:

```text
Kubernetes CronJob
        |
        v
     pg_dump
        |
        v
Compressed SQL Backup
        |
        v
Temporary Volume
        |
        v
AWS CLI Container
        |
        v
       S3
```

The backup Pod uses its own ServiceAccount and IRSA role.

The backup implementation is considered complete only after both backup and restore have been successfully validated.

---

## Helm Usage

Helm is used to deploy third-party Kubernetes components.

The project does not only use default Chart values. Chart structure and templates are inspected to understand how configuration is generated.

Areas being studied include:

- `values.yaml`
- `.Values`
- `with`
- `include`
- `tpl`
- `_helpers.tpl`
- `toYaml`
- `nindent`
- ServiceAccount configuration
- Pod labels
- affinity
- persistence
- securityContext

The goal is to understand the relationship between Helm values and the Kubernetes manifests rendered by the Chart.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Cloud | AWS |
| Kubernetes | Amazon EKS |
| Application Deployment | Helm |
| Application | Nextcloud |
| Database | PostgreSQL |
| Cache / File Locking | Redis |
| Database Storage | Amazon EBS gp3 |
| Planned Shared Storage | Amazon EFS + EFS CSI |
| Load Balancer | AWS Application Load Balancer |
| AWS Controller | AWS Load Balancer Controller |
| Secret Management | AWS Secrets Manager + External Secrets Operator |
| Workload Identity | IAM / OIDC / IRSA |
| Autoscaling | HPA + Karpenter |
| Scheduling | Taints, Tolerations, Affinity, PriorityClass |
| Network Security | Kubernetes NetworkPolicy |
| Metrics | Prometheus / Grafana |
| Logging | Fluent Bit + CloudWatch Logs |
| Backup | Kubernetes CronJob + pg_dump + Amazon S3 |

---

## Kubernetes Resources

| Resource | Purpose |
|---|---|
| Deployment | Nextcloud application workload |
| StatefulSet | Stateful PostgreSQL / Redis workloads |
| Service | Internal Kubernetes networking |
| Ingress | External HTTP routing |
| StorageClass | Dynamic persistent-volume provisioning |
| PersistentVolumeClaim | Application and database persistence |
| Secret | Application credentials |
| ServiceAccount | Kubernetes workload identity |
| HorizontalPodAutoscaler | Application replica scaling |
| ResourceQuota | Namespace resource control |
| LimitRange | Default resource limits |
| NetworkPolicy | Pod-level network restrictions |
| PriorityClass | Scheduling priority |
| Pod Anti-Affinity | Replica distribution across nodes |
| Taint / Toleration | Dedicated database-node isolation |
| Node Affinity | Workload placement |
| CronJob | Scheduled PostgreSQL backup |
| DaemonSet | Fluent Bit node-level log collection |

---

## Repository Structure

```text
.
├── terraform/
│   ├── modules/
│   │   └── vpc/
│   │
│   └── eks/
│       ├── OIDC-IAM/
│       │   ├── oidc.tf
│       │   ├── irsa_alb.tf
│       │   ├── irsa_eso.tf
│       │   ├── irsa_karpenter.tf
│       │   ├── irsa_fluent_bit.tf
│       │   └── irsa_cronjob.tf
│       │
│       ├── helm/
│       │   ├── aws_load_balancer_controller.tf
│       │   ├── eso.tf
│       │   ├── Karpenter.tf
│       │   ├── fluent_bit.tf
│       │   └── nextcloud.tf
│       │
│       ├── values/
│       │   ├── fluent_bit.yaml
│       │   ├── ingress_nginx.yaml
│       │   └── nextcloud.yaml
│       │
│       ├── aws_eks.tf
│       ├── aws_node_group.tf
│       ├── aws_database_node.tf
│       ├── aws_addon.tf
│       ├── aws_acess.tf
│       ├── eks_namespace.tf
│       ├── eks_storageclass.tf
│       ├── eks_networkpolicy.tf
│       ├── eks_hpa.tf
│       ├── eks_priorityclass.tf
│       ├── eks_quota.tf
│       ├── eks_cronjob.tf
│       ├── main.tf
│       ├── tf_state_backed.tf
│       └── tf_variables.tf
│
├── k8s/
│   ├── karpenter_ec2nodeclass.yaml
│   ├── secretstore.yaml
│   └── nextcloud/
│       └── secret/
│
├── README.md
└── nextcloud_helm.md
```

Note:

The Terraform directory structure is currently being refactored.

Terraform does not automatically load `.tf` files recursively from child directories. The `OIDC-IAM` and `helm` directories therefore need to be either converted into proper Terraform modules or reorganized into the root module before the final deployment workflow is considered complete.

---

## Current Scope

The project focuses on a small Nextcloud platform rather than a large enterprise Kubernetes platform.

Current areas of work include:

- Terraform-managed AWS infrastructure
- Amazon EKS
- Multi-AZ networking
- Managed Node Groups
- Dedicated PostgreSQL nodes
- Nextcloud Helm deployment
- PostgreSQL persistence
- Redis caching and file locking
- IAM / OIDC / IRSA
- External Secrets Operator
- AWS Load Balancer Controller
- Kubernetes NetworkPolicy
- Pod Anti-Affinity
- PriorityClass
- HPA
- Karpenter
- Prometheus monitoring
- Fluent Bit logging
- CloudWatch Logs
- PostgreSQL backup to S3
- failure testing
- backup and restore validation

The project intentionally avoids unnecessary complexity such as:

- service mesh
- multi-region Kubernetes
- large-scale database clustering
- complex distributed storage platforms

---

## Project Status

| Phase | Scope | Status |
|---|---|---|
| 1 | VPC and EKS foundation | In Progress |
| 2 | Managed Node Groups | In Progress |
| 3 | Dedicated database node group | In Progress |
| 4 | EBS CSI and PostgreSQL persistence | In Progress |
| 5 | AWS Load Balancer Controller | In Progress |
| 6 | External Secrets Operator and IRSA | In Progress |
| 7 | Nextcloud Helm deployment | In Progress |
| 8 | NetworkPolicy | In Progress |
| 9 | Pod Anti-Affinity and PriorityClass | In Progress |
| 10 | HPA | In Progress |
| 11 | Karpenter | In Progress |
| 12 | Fluent Bit and CloudWatch Logs | In Progress |
| 13 | PostgreSQL backup CronJob | In Progress |
| 14 | Amazon EFS + EFS CSI | Planned |
| 15 | Multi-node Nextcloud RWX validation | Planned |
| 16 | Prometheus / Grafana validation | Planned |
| 17 | Pod and Node failure testing | Planned |
| 18 | Backup and restore validation | Planned |
| 19 | Upgrade and rollback testing | Planned |
| 20 | Final architecture and code audit | Planned |

---

## Validation Goals

The project is not considered complete simply because all resources can be created.

A successful implementation should demonstrate the following:

1. Terraform can initialize, validate, plan, and apply successfully.
2. Kubernetes and Helm providers can connect to the EKS API correctly.
3. Multiple Nextcloud replicas can run across different Kubernetes nodes.
4. All Nextcloud replicas can access the same shared data.
5. PostgreSQL data survives Pod recreation.
6. Redis provides shared caching and transactional file locking.
7. External traffic reaches the application through the intended ALB path.
8. NetworkPolicy allows required traffic and blocks unintended traffic.
9. Credentials are synchronized from AWS Secrets Manager through ESO.
10. AWS-integrated workloads use workload-specific IRSA roles.
11. HPA reacts correctly to application load.
12. Karpenter can provision nodes for unschedulable workloads.
13. Fluent Bit successfully delivers container logs to CloudWatch.
14. PostgreSQL backups are successfully uploaded to S3.
15. A PostgreSQL backup can be restored successfully.
16. Removing one Nextcloud Pod does not make the service unavailable.
17. Removing or replacing a worker node does not permanently break the application.
18. Helm and Kubernetes configuration can survive controlled upgrade and rollback testing.

---

## Engineering Review Goals

Before the project is considered complete, the repository will go through a final review covering:

- Terraform module structure
- Terraform provider configuration
- Helm dependency ordering
- Helm rendered manifests
- namespace consistency
- ServiceAccount ownership
- IAM least privilege
- OIDC / IRSA trust relationships
- Secret names and Secret keys
- storage access modes
- scheduling and storage compatibility
- ingress traffic path
- NetworkPolicy behavior
- HPA behavior
- Karpenter provisioning
- logging
- backup
- restore
- failure recovery
- documentation accuracy

The purpose of this review is to identify integration issues that may not be visible when individual resources are developed separately.

---

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
terraform validate
terraform plan
terraform apply
```

### Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name nextcloud
```

### Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
kubectl get pvc -A
kubectl get hpa -A
kubectl get events -A --sort-by=.lastTimestamp
```

---

## Cost Note

This project creates chargeable AWS resources, including:

- EKS control plane
- EC2 worker nodes
- NAT Gateway
- Application Load Balancer
- EBS volumes
- planned EFS storage
- CloudWatch Logs
- S3 backup storage

AWS Budget alerts are strongly recommended before deployment.

Resources should be destroyed when they are no longer required.

---

## Learning Approach

This repository is intentionally developed as an engineering learning project.

The workflow is:

```text
Learn a concept
      |
      v
Implement it
      |
      v
Integrate it with the existing architecture
      |
      v
Test actual behavior
      |
      v
Review errors and design gaps
      |
      v
Fix and validate
      |
      v
Document the final understanding
```

The project may therefore contain temporary implementation gaps while new components are being introduced.

The objective is not to hide these mistakes, but to use them to understand how Kubernetes, AWS, Terraform, and application infrastructure behave when multiple systems interact.

---

## Project Goal

The goal of this repository is not to create a large enterprise Nextcloud platform.

The goal is to build a small, reproducible, and technically understandable Nextcloud platform on AWS EKS while developing a deeper understanding of:

- Kubernetes
- AWS infrastructure
- Terraform
- IAM and workload identity
- storage
- networking
- scheduling
- autoscaling
- observability
- backup and recovery
- troubleshooting
- system integration

The final objective is not only to make the platform run, but to understand why it works, how it fails, and how it can be recovered.