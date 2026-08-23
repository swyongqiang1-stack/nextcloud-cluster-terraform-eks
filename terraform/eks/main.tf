terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_eks_cluster" "e_cm" {
  name = aws_eks_cluster.e_cm.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.e_cm.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.e_cm.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.e_cm.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = "client.authentication.k8s.io/v1beta1"
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.e_cm.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.e_cm.name]
    command     = "aws"
  }
}


module "vpc" {
  source = "../modules/vpc"
  public_subnet = var.public_subnet
  private_subnet = var.private_subnet
  cidr_block = var.cidr_block
  AZ = var.AZ
} 