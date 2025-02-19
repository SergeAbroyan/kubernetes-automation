# main.tf - Generates an SSH key pair for EC2 instances

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 🚀 Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# 🚀 Save Private Key Locally
resource "local_file" "private_key" {
  filename = "${path.module}/id_rsa"
  content  = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}
