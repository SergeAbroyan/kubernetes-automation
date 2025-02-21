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

resource "local_file" "private_key_file" {
  filename        = "${var.project_root}/self-managed-k8s-karpenter/awsid_rsa"  # 👈 Now correctly writes to project root
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
  depends_on      = [tls_private_key.ssh_key]
}

resource "local_file" "public_key_file" {
  filename        = "${var.project_root}/self-managed-k8s-karpenter/awsid_rsa.pub"  # 👈 Now correctly writes to project root
  content         = tls_private_key.ssh_key.public_key_openssh
  file_permission = "0644"
  depends_on      = [tls_private_key.ssh_key]
}
