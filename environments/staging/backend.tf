terraform {
  backend "s3" {
    bucket         = "kapuletu-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kapuletu-terraform-locks-staging"
    encrypt        = true
  }
}
