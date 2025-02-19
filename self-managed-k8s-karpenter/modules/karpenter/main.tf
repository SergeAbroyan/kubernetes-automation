# main.tf - Deploys Karpenter on Kubernetes

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# 🚀 Install Karpenter Helm Chart
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh/"
  chart      = "karpenter"
  namespace  = "karpenter"
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.karpenter_iam_role
  }

  set {
    name  = "controller.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "controller.aws.defaultInstanceProfile"
    value = var.instance_profile
  }
}

# 🚀 Apply Karpenter Provisioner
resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = yamldecode(file("${path.module}/karpenter-provisioner.yaml"))
}
