# variables.tf - Defines input variables for Load Balancer module

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Load Balancer will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for Load Balancer"
  type        = list(string)
}

variable "worker_node_ids" {
  description = "List of worker node IDs to attach to the Load Balancer"
  type        = list(string)
}

variable "lb_security_group_id" {
  description = "Security group ID for the Load Balancer"
  type        = string
}

variable "service_port" {
  description = "Port on which Kubernetes services will be exposed"
  type        = number
  default     = 80
}
