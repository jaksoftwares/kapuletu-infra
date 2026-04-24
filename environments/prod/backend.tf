terraform {
  backend "s3" {
    bucket         = "kapuletu-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kapuletu-terraform-locks-prod"
    encrypt        = true
  }
}
