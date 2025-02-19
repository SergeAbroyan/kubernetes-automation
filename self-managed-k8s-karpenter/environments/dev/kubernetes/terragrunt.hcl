terraform {
  source = "../../../modules/kubernetes"
}

dependencies {
  paths = ["../ec2"]
}

# 🟢 Mock Outputs for EC2 Module
dependency "ec2" {
  config_path = "../ec2"
  mock_outputs = {
    control_plane_id = "i-1234567890abcdef0"
    control_plane_ip = "54.123.45.67"
    worker_node_ids  = ["i-abcdef1234567890", "i-fedcba0987654321"]
    worker_node_ips  = ["52.11.22.33", "52.44.55.66"]  # ✅ Added worker node IPs
  }
}

inputs = {
  aws_region           = "us-east-1"
  control_plane_id     = dependency.ec2.outputs.control_plane_id
  control_plane_ip     = dependency.ec2.outputs.control_plane_ip
  worker_node_count    = 3
  worker_node_ids      = dependency.ec2.outputs.worker_node_ids
  worker_node_ips      = dependency.ec2.outputs.worker_node_ips  # ✅ Use correct reference
  ssh_private_key_path = "~/.ssh/id_rsa"
}
