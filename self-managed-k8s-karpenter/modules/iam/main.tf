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

### 🚀 CONTROL PLANE IAM ROLE ###
resource "aws_iam_role" "k8s_control_plane" {
  name = "k8s-control-plane-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = { Name = "k8s-control-plane-role" }
}

resource "aws_iam_instance_profile" "k8s_control_plane" {
  name = "k8s-control-plane-instance-profile"
  role = aws_iam_role.k8s_control_plane.name
}

### 🚀 WORKER NODE IAM ROLE ###
resource "aws_iam_role" "k8s_worker_nodes" {
  name = "k8s-worker-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action =  "sts:AssumeRole"
        
    }]
  })

  tags = { Name = "k8s-worker-nodes-role" }
}

resource "aws_iam_instance_profile" "k8s_worker_nodes" {
  name = "k8s-worker-nodes-instance-profile"
  role = aws_iam_role.k8s_worker_nodes.name
}

# ✅ Worker Node Policies (Using `for_each`)
resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.k8s_worker_nodes.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "worker_node_cloudwatch" {
  role       = aws_iam_role.k8s_worker_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


### 🚀 KARPENTER IAM ROLE ###
resource "aws_iam_role" "karpenter" {
  name = "karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = { Name = "karpenter-role" }
}

# ✅ Create a Custom Karpenter Policy for Auto-Scaling & EC2 Actions
resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "KarpenterControllerPolicy"
  description = "IAM policy for Karpenter Controller"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:RunInstances",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages",
          "iam:PassRole",
          "ssm:GetParameter",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:UpdateAutoScalingGroup",
          "iam:GetInstanceProfile"
        ],
        Resource = "*"
      }
    ]
  })
}


# ✅ Attach Karpenter Policy (Dynamically Attached)
resource "aws_iam_role_policy_attachment" "karpenter_controller_attachment" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# ✅ Attach Predefined AWS Policies (Auto-Scaling, EC2, SSM)
resource "aws_iam_role_policy_attachment" "karpenter_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.karpenter.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  name = "karpenter-instance-profile"
  role = aws_iam_role.karpenter.name
}
