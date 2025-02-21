# variables.tf - Defines Key Pair input variables

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH Key Pair"
  type        = string
}

variable "project_root" {
  description = "Path to the root of the project"
  type        = string
}