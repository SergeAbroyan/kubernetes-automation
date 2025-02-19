# variables.tf - Defines Key Pair input variables

variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH Key Pair"
  type        = string
}
