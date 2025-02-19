# main.tf - Configures Kubernetes cluster with kubeadm

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

# 🚀 Install Kubernetes on Control Plane
resource "null_resource" "setup_k8s_control_plane" {
  depends_on = [var.control_plane_id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = var.control_plane_id
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y apt-transport-https curl",
      "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo kubeadm init --pod-network-cidr=192.168.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
  }
}

# 🚀 Install Kubernetes Networking (Calico)
resource "null_resource" "install_calico" {
  depends_on = [null_resource.setup_k8s_control_plane]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = var.control_plane_id
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"
    ]
  }
}

# 🚀 Join Worker Nodes to the Cluster
resource "null_resource" "join_worker_nodes" {
  count      = length(var.worker_node_ips)  # ✅ Use worker_node_ips from EC2
  depends_on = [null_resource.setup_k8s_control_plane]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = var.worker_node_ips[count.index]  # ✅ Use input variable
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y apt-transport-https curl",
      "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo kubeadm join ${var.control_plane_ip}:6443 --token $(kubeadm token create --print-join-command | awk '{print $2}') --discovery-token-ca-cert-hash sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der | openssl dgst -sha256 -hex | awk '{print $2}')"
    ]
  }
}
