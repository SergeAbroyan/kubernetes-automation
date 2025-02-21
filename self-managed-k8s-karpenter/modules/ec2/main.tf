
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
resource "null_resource" "print_path_module" {
  provisioner "local-exec" {
    command = "echo 'path.module: ${path.module}'"
  }
}

resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.control_plane_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.control_plane_iam_role
  

  tags = {
    Name = "k8s-control-plane"
  }
}

resource "aws_instance" "worker_nodes" {
  count                  = var.worker_node_count
  ami                    = var.ami_id
  instance_type          = var.worker_node_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.worker_node_iam_role


  tags = {
    Name = "k8s-worker-node-${count.index}"
  }
}

resource "null_resource" "generate_ansible_inventory" {
  provisioner "local-exec" {
    command = <<EOT
    INVENTORY_FILE="${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini"

    # ✅ Master Node
    echo "[master]" > $INVENTORY_FILE
    echo "control-plane ansible_host=${aws_instance.control_plane.public_ip} ansible_user=ec2-user" >> $INVENTORY_FILE

    # ✅ Worker Nodes
    echo "[workers]" >> $INVENTORY_FILE
    %{ for ip in aws_instance.worker_nodes[*].private_ip ~}
    echo "worker ansible_host=${ip} ansible_user=ec2-user" >> $INVENTORY_FILE
    %{ endfor }

    # ✅ Ansible SSH ProxyCommand (To allow workers to connect through the control-plane)
    echo "[all:vars]" >> $INVENTORY_FILE
    echo "ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa -W %h:%p -q ec2-user@${aws_instance.control_plane.public_ip}\"'" >> $INVENTORY_FILE

    echo "✅ Inventory file created at: $INVENTORY_FILE"
    cat $INVENTORY_FILE
    EOT
  }

  depends_on = [
    aws_instance.control_plane,
    aws_instance.worker_nodes
  ]
}




resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.control_plane]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.project_root}/self-managed-k8s-karpenter/awsid_rsa")
      host        = aws_instance.control_plane.public_ip
    }

    inline = [
      "echo 'Installing nc (netcat)...'",
      "sudo yum install -y nc",
      "echo 'Waiting for SSH to be ready...'",
      "while ! nc -z localhost 22; do sleep 5; done",
      "echo '✅ SSH is now available! Proceeding with Ansible...'"
    ]
  }
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = <<EOT
    ansible-playbook -i ${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini -u ec2-user --private-key ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa ${var.project_root}/self-managed-k8s-karpenter/ansible/playbooks/install-k8s-master.yaml
    ansible-playbook -i ${var.project_root}/self-managed-k8s-karpenter/ansible/inventory.ini -u ec2-user --private-key ${var.project_root}/self-managed-k8s-karpenter/awsid_rsa ${var.project_root}/self-managed-k8s-karpenter/ansible/playbooks/install-k8s-workers.yaml
   EOT
  }

  depends_on = [
    null_resource.generate_ansible_inventory,
    null_resource.wait_for_ssh  # ✅ Wait until SSH is ready
  ]
}


