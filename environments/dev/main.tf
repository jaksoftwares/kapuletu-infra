# --- Kapuletu Development Environment Configuration ---
# This file orchestrates the instantiation of reusable modules for the 'dev' environment.

# Networking: Creates the VPC, subnets, and security groups.
module "networking" {
  source = "../../modules/networking"
  env    = var.environment
}

# IAM: Manages execution roles and OIDC roles for CI/CD.
module "iam" {
  source = "../../modules/iam"
  env    = var.environment
}

# RDS: Deploys a single-instance PostgreSQL database for Dev.
module "rds" {
  source       = "../../modules/rds"
  env          = var.environment
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnets
  multi_az     = false # Multi-AZ disabled for cost-efficiency in Dev
  instance_class = "db.t3.micro"
}

# QLDB: Immutable ledger for transaction audit trails.
module "qldb" {
  source = "../../modules/qldb"
  env    = var.environment
}

# S3: Object storage for application assets and backend artifacts.
module "s3" {
  source = "../../modules/s3"
  env    = var.environment
}

# Secrets Manager: Secure storage for database credentials and API keys.
module "secrets_manager" {
  source = "../../modules/secrets_manager"
  env    = var.environment
}

# Lambda: Serverless business logic functions.
module "lambda" {
  source          = "../../modules/lambda"
  env             = var.environment
  role_arn        = module.iam.lambda_role_arn
  artifact_bucket = module.s3.bucket_name
  artifact_key    = "backend.zip" # Expected zip file path in S3
}

# API Gateway: Exposes HTTP endpoints and handles Cognito JWT auth.
module "api_gateway" {
  source      = "../../modules/api_gateway"
  env         = var.environment
  lambda_arn  = module.lambda.function_arn
  user_pool_arn = module.cognito.user_pool_arn
}

# Cognito: Identity management and user authentication.
module "cognito" {
  source = "../../modules/cognito"
  env    = var.environment
}

# Monitoring: Centralized logging and alerting.
module "monitoring" {
  source = "../../modules/monitoring"
  env    = var.environment
}
