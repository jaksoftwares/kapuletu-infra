# VPC Resource: Defines the isolated network boundary for the environment.
# We use a /16 CIDR block to allow for future subnet expansion.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # Required for certain AWS services like RDS
  enable_dns_support   = true

  tags = {
    Name = "kapuletu-${var.env}-vpc"
    Env  = var.env
  }
}

# Internet Gateway: Allows communication between the VPC and the internet.
# This is attached to the VPC to enable public subnet traffic.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "kapuletu-${var.env}-igw"
  }
}
