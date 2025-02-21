terraform {
  source = "../../../modules/key-pair"
}

locals {
  project_root = get_env("TERRAGRUNT_WORKING_DIR", get_repo_root())
}

inputs = {
  aws_region   = "us-east-1"
  key_name     = "k8s-key-pair"
  project_root = local.project_root  # 👈 Pass project root to Terraform
}
