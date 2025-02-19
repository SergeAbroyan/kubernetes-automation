# variables.tf - Defines input variables for Kubernetes module

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "control_plane_id" {
  description = "ID of the control plane instance"
  type        = string
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "worker_node_ids" {
  description = "IDs of the worker nodes"
  type        = list(string)
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}
