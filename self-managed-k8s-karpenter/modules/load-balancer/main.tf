# main.tf - Deploys an AWS Load Balancer for Kubernetes services

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

# 🚀 Create an Application Load Balancer (ALB)
resource "aws_lb" "k8s_alb" {
  name               = "k8s-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "k8s-alb"
  }
}

# 🚀 Create an ALB Target Group
resource "aws_lb_target_group" "k8s_tg" {
  name     = "k8s-target-group"
  port     = var.service_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "k8s-target-group"
  }
}

# 🚀 Attach Worker Nodes to Target Group
resource "aws_lb_target_group_attachment" "k8s_worker_nodes" {
  count            = length(var.worker_node_ids)
  target_group_arn = aws_lb_target_group.k8s_tg.arn
  target_id        = var.worker_node_ids[count.index]
  port             = var.service_port
}

# 🚀 Create an ALB Listener
resource "aws_lb_listener" "k8s_listener" {
  load_balancer_arn = aws_lb.k8s_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.k8s_tg.arn
  }
}
