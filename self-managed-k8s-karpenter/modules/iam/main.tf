
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

resource "aws_iam_role" "k8s_control_plane" {
  name = "k8s-control-plane-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "k8s-control-plane-role"
  }
}

resource "aws_iam_role" "k8s_worker_nodes" {
  name = "k8s-worker-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "k8s-worker-nodes-role"
  }
}


resource "aws_iam_instance_profile" "k8s_control_plane" {
  name = "k8s-control-plane-instance-profile"
  role = aws_iam_role.k8s_control_plane.name
}

resource "aws_iam_instance_profile" "k8s_worker_nodes" {
  name = "k8s-worker-nodes-instance-profile"
  role = aws_iam_role.k8s_worker_nodes.name
}


resource "aws_iam_role_policy_attachment" "worker_node_policy_eks" {
  role       = aws_iam_role.k8s_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_ec2" {
  role       = aws_iam_role.k8s_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_ssm" {
  role       = aws_iam_role.k8s_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "karpenter" {
  name = "karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "karpenter-role"
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_ec2" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_autoscaling" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_ssm" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

