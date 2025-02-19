# terragrunt.hcl - Config for Terragrunt Security Groups module

terraform {
  source = "../../../modules/security-groups"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"  # Temporary mock output
  }
}

inputs = {
  aws_region      = "us-east-1"
  vpc_id          = dependency.vpc.outputs.vpc_id
  allowed_ssh_cidrs = ["0.0.0.0/0"]
}
