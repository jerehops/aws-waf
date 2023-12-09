# List of providers available
# Comes from the facts file for the project
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }
}
