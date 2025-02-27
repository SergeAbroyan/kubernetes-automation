# variables.tf - Defines input variables for EC2 module

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}


variable "control_plane_instance_type" {
  description = "Instance type for control plane node"
  type        = string
}

variable "worker_node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "key_pair_name" {
  description = "SSH Key Pair for EC2 instances"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for the control plane"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet for worker nodes"
  type        = string
}

variable "security_group_id" {
  description = "Security group for Kubernetes nodes"
  type        = string
}

variable "control_plane_iam_role" {
  description = "IAM role for control plane node"
  type        = string
}

variable "worker_node_iam_role" {
  description = "IAM role for worker nodes"
  type        = string
}

variable "project_root" {
  description = "Path to the root of the project"
  type        = string
}