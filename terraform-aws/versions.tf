terraform {
  required_version = ">= 1.16"

  # Bucket/key/region are supplied per account at init time via -backend-config
  # (see accounts/<account_id>.backend.hcl) so each AWS account keeps its own state.
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
