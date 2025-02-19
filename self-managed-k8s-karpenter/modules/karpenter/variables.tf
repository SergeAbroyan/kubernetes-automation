# variables.tf - Defines input variables for Karpenter module

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "karpenter_iam_role" {
  description = "IAM Role ARN for Karpenter"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "instance_profile" {
  description = "EC2 instance profile for Karpenter"
  type        = string
}
