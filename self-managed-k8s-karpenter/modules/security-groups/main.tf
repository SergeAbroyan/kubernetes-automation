
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

resource "aws_security_group" "k8s_nodes" {
  name        = "k8s-nodes-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from trusted sources"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "Allow Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

 # Allow Node-to-Node Kubernetes Traffic
ingress {
  description = "Allow Kubernetes NodePort Range"
  from_port   = 30000
  to_port     = 32767
  protocol    = "tcp"
  self        = true
}

# Allow Cluster Networking
ingress {
  description = "Allow Kubernetes Internal Services"
  from_port   = 10250
  to_port     = 10255
  protocol    = "tcp"
  self        = true
}

# Allow Calico / Flannel CNI
ingress {
  description = "Allow VXLAN / BGP for CNI (Calico, Flannel)"
  from_port   = 4789
  to_port     = 4789
  protocol    = "udp"
  self        = true
}


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-nodes-sg"
  }
}

resource "aws_security_group" "load_balancer" {
  name        = "load-balancer-sg"
  description = "Security group for Kubernetes Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer-sg"
  }
}
