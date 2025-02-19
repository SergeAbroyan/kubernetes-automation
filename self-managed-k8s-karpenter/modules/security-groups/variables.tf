# variables.tf - Defines security group input variables

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security groups"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into Kubernetes nodes"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
