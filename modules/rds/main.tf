# DB Subnet Group: Defines which subnets the RDS instance can be deployed into.
# Must include subnets in at least two Availability Zones for Multi-AZ deployments.
resource "aws_db_subnet_group" "main" {
  name       = "kapuletu-${var.env}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "kapuletu-${var.env}-db-subnet-group"
  }
}

# RDS Instance: Managed PostgreSQL database.
# In production, 'multi_az' is enabled for failover support.
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.instance_class
  db_name              = "kapuletu_${var.env}"
  username             = "postgres"
  password             = "REPLACE_WITH_SECRETS_MANAGER" # Initial password; should be managed via Secrets Manager
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  multi_az             = var.multi_az
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "kapuletu-${var.env}-rds"
    Env  = var.env
  }
}

# RDS Security Group: Controls network access to the database.
# Restricts ingress to the VPC CIDR block for maximum security.
resource "aws_security_group" "rds" {
  name        = "kapuletu-${var.env}-rds-sg"
  description = "Allow traffic to RDS from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Only allow traffic from within the VPC
  }
}
