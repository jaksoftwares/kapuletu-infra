resource "aws_secretsmanager_secret" "db_credentials" {
  name = "kapuletu-${var.env}-db-credentials-v2"
  description = "Database credentials for ${var.env}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "postgres"
    password = "change-me-manually-in-console"
  })
}

resource "aws_secretsmanager_secret" "api_keys" {
  name = "kapuletu-${var.env}-api-keys"
  description = "External API keys for ${var.env}"
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

variable "env" {
  type = string
}
