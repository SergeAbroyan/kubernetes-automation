terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var", "aws_region=us-east-1"
    ]
  }
}

# Define dependencies for correct execution order
dependencies {
  paths = [
    "./vpc",
    "./security-groups",
    "./key-pair",
    "./iam",
    "./ec2",
    "./load-balancer"
  ]
}

inputs = {
  aws_region = "us-east-1"
}
