# Terraform Version and Provider Locks:
# Ensures that all team members and CI/CD runners use compatible versions of Terraform and its providers.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Lock to version 5.x to prevent breaking changes from future major releases
    }
  }
}
