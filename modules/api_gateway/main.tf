# HTTP API Gateway: The entry point for the fintech application.
resource "aws_apigatewayv2_api" "main" {
  name          = "kapuletu-${var.env}-api"
  protocol_type = "HTTP"
}

# JWT Authorizer: Validates incoming requests against the Cognito User Pool.
# Ensures only authenticated users can access sensitive transaction routes.
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "kapuletu-${var.env}-authorizer"

  jwt_configuration {
    audience = ["kapuletu-client-id"] # Replace with actual Cognito Client ID
    issuer   = "https://${var.user_pool_endpoint}"
  }
}

# --- Routes ---

# Public Ingestion Route: Receives webhooks from external providers.
resource "aws_apigatewayv2_route" "ingestion" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /ingestion/webhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Private Transactions Route: Lists pending transactions for authenticated users.
resource "aws_apigatewayv2_route" "pending_transactions" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /transactions/pending"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# Private Approval Route: Approves a specific transaction.
resource "aws_apigatewayv2_route" "approve_transaction" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /transactions/{id}/approve"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# Lambda Integration: Connects API Gateway routes to the backend Lambda function.
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_arn
}

# API Stage: Deploys the API to the '$default' stage with auto-deployment.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}
