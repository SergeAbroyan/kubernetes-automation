terraform {
  source = "../../../modules/load-balancer"
}

dependencies {
  paths = ["../kubernetes", "../vpc", "../security-groups"]
}

# 🟢 Mock Outputs for VPC Module
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id         = "vpc-12345678"      # Temporary VPC ID
    public_subnets = ["subnet-11111111", "subnet-22222222"] # Temporary Public Subnet IDs
  }
}

# 🟢 Mock Outputs for Kubernetes Module
dependency "kubernetes" {
  config_path = "../kubernetes"
  mock_outputs = {
    worker_node_ids = ["i-abcdef1234567890", "i-fedcba0987654321"] # Temporary Worker Node IDs
  }
}

# 🟢 Mock Outputs for Security Groups Module
dependency "security-groups" {
  config_path = "../security-groups"
  mock_outputs = {
    k8s_nodes_sg = "sg-33333333"  # Temporary Security Group ID
  }
}

inputs = {
  aws_region           = "us-east-1"
  vpc_id               = dependency.vpc.outputs.vpc_id
  public_subnet_ids    = dependency.vpc.outputs.public_subnets
  worker_node_ids      = dependency.kubernetes.outputs.worker_node_ids
  lb_security_group_id = dependency.security-groups.outputs.k8s_nodes_sg
  service_port         = 80
}
