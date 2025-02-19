terraform {
  source = "${get_repo_root()}/modules/${path_relative_to_include()}"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-bucket-kubernetes"
    key            = "state/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

inputs = {
  aws_region  = "us-east-1"
  environment = "dev"
}
