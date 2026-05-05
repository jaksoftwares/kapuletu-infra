resource "aws_cognito_user_pool" "main" {
  name = "kapuletu-${var.env}-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email", "phone_number"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = true
  }

  schema {
    name                     = "given_name"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = true
  }

  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = true
  }

  schema {
    name                     = "phone_number"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "kapuletu-${var.env}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.main.arn
}

output "user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}

variable "env" {
  type = string
}
