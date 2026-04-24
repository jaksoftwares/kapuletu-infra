terraform {
  backend "s3" {
    bucket         = "kapuletu-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kapuletu-terraform-locks-dev"
    encrypt        = true
  }
}
