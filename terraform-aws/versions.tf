terraform {
  required_version = ">= 1.16"

  backend "s3" {
    bucket = "testbucket-611182197776-eu-west-3-an"
    key    = "terraform.tfstate"
    region = "eu-west-3"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
