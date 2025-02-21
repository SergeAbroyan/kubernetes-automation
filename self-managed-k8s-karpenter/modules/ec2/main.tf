# main.tf - Defines EC2 instances for Kubernetes control plane and worker nodes

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

# 🚀 Launch Control Plane Node
resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.control_plane_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.control_plane_iam_role


  user_data = <<-EOF
      #!/bin/bash
      set -e
      apt-get update
      apt-get install -y docker.io kubeadm kubelet kubectl
      systemctl enable --now docker
      systemctl enable --now kubelet

      # Initialize Kubernetes Control Plane
      kubeadm init --pod-network-cidr=192.168.0.0/16

      # Configure kubectl for root user
      mkdir -p /root/.kube
      cp -i /etc/kubernetes/admin.conf /root/.kube/config
      chown root:root /root/.kube/config

      # Install CNI (Calico)
      kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

      # Save worker node join command
      kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
    EOF

  tags = {
    Name = "k8s-control-plane"
  }
}

# 🚀 Launch Worker Nodes
resource "aws_instance" "worker_nodes" {
  count                  = var.worker_node_count
  ami                    = var.ami_id
  instance_type          = var.worker_node_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.worker_node_iam_role


  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update
    apt-get install -y docker.io kubeadm kubelet kubectl
    systemctl enable --now docker
    systemctl enable --now kubelet

    # Wait for join command from Control Plane
    while [ ! -f /home/ubuntu/join-command.sh ]; do sleep 5; done
    bash /home/ubuntu/join-command.sh
  EOF

  tags = {
    Name = "k8s-worker-node-${count.index}"
  }
}
