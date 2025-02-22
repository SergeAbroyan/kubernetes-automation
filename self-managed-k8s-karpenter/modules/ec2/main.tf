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

### 🚀 Create EC2 Instances: Control Plane & Worker Nodes ###
resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.control_plane_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.control_plane_iam_role

  tags = { Name = "k8s-control-plane" }
}

resource "aws_instance" "worker_nodes" {
  count                  = var.worker_node_count
  ami                    = var.ami_id
  instance_type          = var.worker_node_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.worker_node_iam_role

  tags = { Name = "k8s-worker-node-${count.index}" }
}

### 🚀 Generate Ansible Inventory File ###
resource "null_resource" "generate_ansible_inventory" {
  provisioner "local-exec" {
    command = <<EOT
    INVENTORY_FILE="${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini"

    echo "[master]" > $INVENTORY_FILE
    echo "control-plane ansible_host=${aws_instance.control_plane.public_ip} ansible_user=ec2-user" >> $INVENTORY_FILE

    echo "[workers]" >> $INVENTORY_FILE
    %{ for ip in aws_instance.worker_nodes[*].private_ip ~}
    echo "worker ansible_host=${ip} ansible_user=ec2-user" >> $INVENTORY_FILE
    %{ endfor }

    echo "[all:vars]" >> $INVENTORY_FILE
    echo "ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa -W %h:%p -q ec2-user@${aws_instance.control_plane.public_ip}\"'" >> $INVENTORY_FILE

    echo "✅ Inventory file created at: $INVENTORY_FILE"
    cat $INVENTORY_FILE
    EOT
  }

  depends_on = [aws_instance.control_plane, aws_instance.worker_nodes]
}

resource "null_resource" "setup_bastion" {
  depends_on = [aws_instance.control_plane]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.project_root}/self-managed-k8s-karpenter/awsid_rsa")
      host        = aws_instance.control_plane.public_ip
    }

    inline = [
      "echo '⏳ Waiting for SSH on Control Plane...'",

      # ✅ Loop until SSH is available
      "until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes -i /home/ec2-user/.ssh/awsid_rsa ec2-user@${aws_instance.control_plane.public_ip} exit; do",
      "  echo '⏳ Waiting for SSH to be available on Control Plane...'",
      "  sleep 5",
      "done",
      "echo '✅ Control Plane SSH is Ready!'",

      # ✅ Copy SSH Key to Bastion
      "echo '🔑 Copying SSH private key to Bastion (Control Plane)...'",
      "mkdir -p /home/ec2-user/.ssh",
      "echo '${file("${var.project_root}/self-managed-k8s-karpenter/awsid_rsa")}' > /home/ec2-user/.ssh/awsid_rsa",
      "chmod 600 /home/ec2-user/.ssh/awsid_rsa",
      "chown ec2-user:ec2-user /home/ec2-user/.ssh/awsid_rsa",
      "echo '✅ Private key copied successfully!'"
    ]
  }
}


### 🚀 Install Kubernetes on the Master Node ###
resource "null_resource" "ansible_install_k8s_master" {
  provisioner "local-exec" {
    command = <<EOT
    echo "⏳ Running Ansible: Installing Kubernetes on Master Node..."
    
    ansible-playbook -i ${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini -u ec2-user \
      --private-key ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa \
      ${var.project_root}/self-managed-k8s-karpenter/ansible/playbooks/install-k8s-master.yaml
    EOT
  }

  depends_on = [
    null_resource.generate_ansible_inventory,
    null_resource.setup_bastion
  ]
}

resource "null_resource" "ansible_install_k8s_worker" {
  provisioner "local-exec" {
    command = <<EOT
    echo "⏳ Running Ansible: Installing Kubernetes on Worker Nodes..."
    
    ansible-playbook -i ${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini \
      -u ec2-user \
      --private-key /Users/serge/Documents/GitHub/kubernetes-automation/self-managed-k8s-karpenter/awsid_rsa \
      --ssh-extra-args "-o ProxyCommand=\"ssh -i /Users/serge/Documents/GitHub/kubernetes-automation/self-managed-k8s-karpenter/awsid_rsa -W %h:%p -q ec2-user@${aws_instance.control_plane.public_ip}\"" \
      ${var.project_root}/self-managed-k8s-karpenter/ansible/playbooks/install-k8s-workers.yaml
    EOT
  }

  depends_on = [
    null_resource.ansible_install_k8s_master  # ✅ Ensure Master is installed first
  ]
}




### 🚀 Ensure Kubernetes Cluster is Fully Ready ###
resource "null_resource" "wait_for_cluster_ready" {
  depends_on = [null_resource.ansible_install_k8s_worker]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.project_root}/self-managed-k8s-karpenter/awsid_rsa")
      host        = aws_instance.control_plane.public_ip
    }

    inline = [
      "echo '🔄 Waiting for Kubernetes Cluster to be Fully Ready...'",
      "until kubectl get nodes --kubeconfig /home/ec2-user/.kube/config | grep 'Ready'; do",
      "  echo '⏳ Waiting for all nodes to be Ready...'",
      "  sleep 10",
      "done",
      "echo '✅ Kubernetes Cluster is Fully Ready!'"
    ]
  }
}

### 🚀 Deploy Karpenter ###
resource "null_resource" "ansible_deploy_karpenter" {
  provisioner "local-exec" {
    command = <<EOT
    echo "⏳ Running Ansible: Deploying Karpenter..."
    
    ansible-playbook -i ${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini \
      -u ec2-user --private-key ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa \
      ${var.project_root}/self-managed-k8s-karpenter/ansible/playbooks/deploy-karpenter.yaml
    EOT
  }

  depends_on = [
    null_resource.wait_for_cluster_ready
  ]
}
