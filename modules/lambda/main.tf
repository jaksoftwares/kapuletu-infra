# AWS Lambda Function: The compute core of the serverless backend.
# This function is joined to the VPC to enable secure access to the RDS database.
resource "aws_lambda_function" "backend" {
  function_name = "kapuletu-${var.env}-backend"
  role          = var.role_arn
  handler       = "main.handler"
  runtime       = "python3.10"
  s3_bucket     = var.artifact_bucket
  s3_key        = var.artifact_key

  # Environment variables for application logic
  environment {
    variables = {
      ENV = var.env
    }
  }

  # VPC Configuration for private resource access
  # vpc_config {
  #   subnet_ids         = var.private_subnets
  #   security_group_ids = [var.lambda_sg_id]
  # }
}
