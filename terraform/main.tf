terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.57.1"
    }
  }
}

# AWS provider for resources
provider "aws" {
  alias  = var.region
  region = var.region
}

# AWS provider zone for SSL certificates
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}