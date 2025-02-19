# terragrunt.hcl - Config for Terragrunt IAM module

terraform {
  source = "../../../modules/iam"
}

inputs = {
  aws_region = "us-east-1"
}
