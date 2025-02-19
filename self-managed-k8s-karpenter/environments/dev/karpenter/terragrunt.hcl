terraform {
  source = "../../../modules/karpenter"
}

dependencies {
  paths = ["../kubernetes", "../iam"]
}

# 🟢 Mock Outputs for Kubernetes Module
dependency "kubernetes" {
  config_path = "../kubernetes"
  mock_outputs = {
    kubeconfig = "/tmp/mock-kubeconfig"  # Temporary path for kubeconfig
  }
}

# 🟢 Mock Outputs for IAM Module
dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    karpenter_role  = "arn:aws:iam::123456789012:role/karpenter-role"  # Temporary IAM Role ARN
    worker_nodes_role = "arn:aws:iam::123456789012:role/worker-nodes-role" # Temporary IAM Role ARN
  }
}

inputs = {
  aws_region         = "us-east-1"
  kubeconfig_path    = dependency.kubernetes.outputs.kubeconfig
  karpenter_iam_role = dependency.iam.outputs.karpenter_role
  cluster_name       = "self-managed-k8s-cluster"
  instance_profile   = dependency.iam.outputs.worker_nodes_role
}
