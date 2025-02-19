# terragrunt.hcl - Config for Terragrunt VPC module

terraform {
  source = "../../../modules/vpc"
}


inputs = {
  aws_region         = "us-east-1"
  vpc_cidr           = "10.0.0.0/16"
  vpc_name           = "self-managed-k8s-vpc"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}
