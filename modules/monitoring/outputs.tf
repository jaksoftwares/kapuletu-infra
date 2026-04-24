# Exported values for observability.
output "log_group_name" {
  description = "The name of the primary CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}
