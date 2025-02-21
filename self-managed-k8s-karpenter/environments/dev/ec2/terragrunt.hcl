terraform {
  source = "../../../modules/ec2"
}

dependencies {
  paths = ["../vpc", "../security-groups", "../key-pair", "../iam"]
}

# 🟢 Mock Outputs for VPC Module
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = "vpc-12345678"      # Temporary VPC ID
    public_subnets  = ["subnet-11111111"] # Temporary Public Subnet
    private_subnets = ["subnet-22222222"] # Temporary Private Subnet
  }
}

# 🟢 Mock Outputs for Security Groups Module
dependency "security-groups" {
  config_path = "../security-groups"
  mock_outputs = {
    k8s_nodes_sg = "sg-33333333" # Temporary Security Group ID
  }
}

# 🟢 Mock Outputs for Key Pair Module
dependency "key-pair" {
  config_path = "../key-pair"
  mock_outputs = {
    key_name = "key_name" # Temporary Key Name
  }
}

# 🟢 Mock Outputs for IAM Module
dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    control_plane_instance_profile = "k8s-control-plane-instance-profile"  # Mock IAM Instance Profile Name
    worker_nodes_instance_profile  = "k8s-worker-nodes-instance-profile"   # Mock IAM Instance Profile Name
  }
}

locals {
  project_root = get_env("TERRAGRUNT_WORKING_DIR", get_repo_root())
}

inputs = {
  aws_region                  = "us-east-1"
  ami_id                      = "ami-04681163a08179f28" # Change this to the correct Kubernetes AMI
  control_plane_instance_type = "t3.medium"
  worker_node_instance_type   = "t3.medium"
  worker_node_count           = 1
  key_pair_name               = dependency.key-pair.outputs.key_name
  public_subnet_id            = dependency.vpc.outputs.public_subnets[0]
  private_subnet_id           = dependency.vpc.outputs.private_subnets[0]
  security_group_id           = dependency.security-groups.outputs.k8s_nodes_sg
  control_plane_iam_role      = dependency.iam.outputs.control_plane_instance_profile  # ✅ FIXED REFERENCE
  worker_node_iam_role        = dependency.iam.outputs.worker_nodes_instance_profile   # ✅ FIXED REFERENCE
  project_root                = local.project_root  
}
