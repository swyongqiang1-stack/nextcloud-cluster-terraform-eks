# Nextcloud on AWS EKS

A hands-on infrastructure project for deploying Nextcloud on AWS EKS with Terraform, Kubernetes, and Helm.

The goal is to build a reproducible platform with persistent storage, workload identity, monitoring, and backup recovery.

> **Status:** Work in progress. Configuration exists for the main components, but end-to-end deployment and recovery have not yet been validated. This repository is not production-ready.

## Target Architecture

```text
Internet
   |
   v
AWS ALB
   |
   v
Nextcloud Service
   |
   v
Nextcloud Pods ────── EFS (shared application storage)
   |
   +── PostgreSQL ── EBS gp3
   |
   +── Redis (cache and file locking)
```

Supporting services:

- **Secrets:** AWS Secrets Manager → External Secrets Operator → Kubernetes Secrets
- **AWS permissions:** IAM Roles for Service Accounts (IRSA)
- **Monitoring:** Prometheus and Grafana
- **Logging:** Fluent Bit → CloudWatch Logs
- **Database backup:** PostgreSQL dump → S3
- **Scaling:** HPA for application replicas; Karpenter for node provisioning

EFS shared storage is planned. The current Nextcloud configuration still uses EBS-backed volumes and requires changes before multi-node replicas can operate correctly.

## Technology Stack

| Area | Technologies |
|---|---|
| Infrastructure | Terraform, AWS VPC, EKS, managed node groups |
| Application | Helm, Nextcloud, PostgreSQL, Redis |
| Storage | EBS gp3; planned EFS with EFS CSI |
| Networking and security | ALB, NetworkPolicy, IAM/IRSA, External Secrets |
| Operations | Prometheus, Grafana, Fluent Bit, CloudWatch, S3 |
| Automation | GitHub Actions, HPA, Karpenter |

PostgreSQL runs inside Kubernetes for this project. Dedicated database nodes provide scheduling isolation; they do not by themselves provide database high availability.

## Repository Layout

```text
.
├── terraform/
│   ├── modules/vpc/       # VPC, subnets, routing and NAT
│   └── eks/
│       ├── helm_chart/    # Helm release definitions
│       ├── oidc_iam/      # Workload identity and IAM policies
│       ├── values/        # Helm values
│       └── *.tf           # EKS and Kubernetes resources
├── k8s/                   # Additional Kubernetes manifests
├── .github/workflows/     # CI configuration
└── README.md
```

The Terraform structure is being reorganized. Child directories are not automatically loaded and must be explicitly integrated before deployment.

## Current Progress

| Area | Status |
|---|---|
| VPC, EKS and managed node groups | Configuration written; validation pending |
| Application, IAM, secrets and ingress | Configuration written; integration fixes required |
| PostgreSQL persistence and network policies | Corrections and runtime testing required |
| Monitoring, logging and database backup | Partial implementation; verification pending |
| EFS shared storage and multi-node Nextcloud | Planned |
| HPA and Karpenter | Partial implementation |
| Restore, failure recovery and upgrade testing | Pending |

## Deployment Preparation

Required tools:

- Terraform
- AWS CLI
- kubectl
- Helm

Deployment also requires AWS credentials, a Terraform state backend, network configuration, application secrets, and a domain with an ACM certificate for HTTPS.

**The deployment workflow is not yet ready for unattended use.** The intended implementation order is:

1. Provision networking, EKS and storage drivers.
2. Configure workload identity and secret synchronization.
3. Validate a single Nextcloud replica with PostgreSQL and Redis.
4. Configure ALB, HTTPS and network policies.
5. Verify persistence, backups and restoration.
6. Add observability, shared storage and autoscaling.

## Completion Criteria

The project will be considered complete when:

- Infrastructure and applications can be deployed using documented steps.
- HTTPS access, login, upload and download work.
- Application and database data survive Pod recreation.
- Required traffic is allowed and unintended traffic is blocked.
- Logs, metrics and actionable alerts are available.
- Backups can restore a working Nextcloud instance, including its files and configuration.
- Multi-node replicas, scaling and controlled failure recovery are tested.

## Cost and Cleanup

This project provisions chargeable AWS resources, including EKS, EC2, NAT Gateways, load balancers, storage and logging.

Set a budget before deployment. When removing the environment, review retained volumes, EFS data, backups and Terraform state separately; destroying compute resources does not necessarily remove all storage or ongoing charges.