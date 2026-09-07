terraform {
  required_version = ">= 1.16"

  backend "oci" {
    namespace = "axfv8xrxtwid"
    bucket    = "terraform-state"
    key       = "terraform.tfstate"
    region    = "eu-paris-1"
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}