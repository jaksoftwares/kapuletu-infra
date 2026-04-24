# --- Kapuletu Staging Environment Configuration ---
# Orchestrates the infrastructure for the Staging/QA environment.
# Inherits the same modular structure as Dev but can have isolated scaling/parameters.

module "networking" {
  source = "../../modules/networking"
  env    = var.environment
}

module "iam" {
  source = "../../modules/iam"
  env    = var.environment
}

module "rds" {
  source       = "../../modules/rds"
  env          = var.environment
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnets
  multi_az     = false # Usually disabled in Staging to save costs, unless testing failover
  instance_class = "db.t3.small"
}

module "qldb" {
  source = "../../modules/qldb"
  env    = var.environment
}

module "s3" {
  source = "../../modules/s3"
  env    = var.environment
}

module "secrets_manager" {
  source = "../../modules/secrets_manager"
  env    = var.environment
}

module "lambda" {
  source          = "../../modules/lambda"
  env             = var.environment
  role_arn        = module.iam.lambda_role_arn
  artifact_bucket = module.s3.bucket_name
  artifact_key    = "backend.zip"
}

module "api_gateway" {
  source      = "../../modules/api_gateway"
  env         = var.environment
  lambda_arn  = module.lambda.function_arn
  user_pool_arn = module.cognito.user_pool_arn
}

module "cognito" {
  source = "../../modules/cognito"
  env    = var.environment
}

module "monitoring" {
  source = "../../modules/monitoring"
  env    = var.environment
}
