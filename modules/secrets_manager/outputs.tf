# Exported values for sensitive data access.
output "db_secret_arn" {
  description = "The ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "api_keys_secret_arn" {
  description = "The ARN of the API keys secret"
  value       = aws_secretsmanager_secret.api_keys.arn
}
