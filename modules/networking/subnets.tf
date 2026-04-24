# Public Subnets: Used for resources that need direct internet access (e.g., Load Balancers, NAT Gateways).
# These subnets have 'map_public_ip_on_launch' set to true.
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "us-east-1a" # Ideally spread across AZs (e.g., via a variable)
  map_public_ip_on_launch = true

  tags = {
    Name = "kapuletu-${var.env}-public-${count.index}"
  }
}

# Private Subnets: Used for sensitive resources (e.g., Databases, App Servers).
# No direct internet access; traffic must go through a NAT Gateway or VPN.
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "kapuletu-${var.env}-private-${count.index}"
  }
}
