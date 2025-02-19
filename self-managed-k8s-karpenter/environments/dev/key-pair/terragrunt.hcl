# terragrunt.hcl - Config for Terragrunt Key Pair module

terraform {
  source = "../../../modules/key-pair"
}

inputs = {
  aws_region = "us-east-1"
  key_name   = "k8s-key-pair"
}
