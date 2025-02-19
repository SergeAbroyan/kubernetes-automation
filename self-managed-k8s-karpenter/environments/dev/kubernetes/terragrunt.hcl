terraform {
  source = "../../../modules/kubernetes"
}

dependencies {
  paths = ["../ec2"]
}

# 🟢 Mock Outputs for EC2 Module (Control Plane & Worker Nodes)
dependency "ec2" {
  config_path = "../ec2"
  mock_outputs = {
    control_plane_id = "i-1234567890abcdef0"  # Temporary EC2 Instance ID for Control Plane
    worker_node_ids  = ["i-abcdef1234567890", "i-fedcba0987654321"] # Temporary Worker Node IDs
  }
}

inputs = {
  aws_region           = "us-east-1"
  control_plane_id     = dependency.ec2.outputs.control_plane_id
  worker_node_count    = 3
  worker_node_ids      = dependency.ec2.outputs.worker_node_ids
  ssh_private_key_path = "~/.ssh/id_rsa"
}
