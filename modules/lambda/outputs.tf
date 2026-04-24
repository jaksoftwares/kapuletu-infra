# Exported values for the Lambda module.
output "function_name" {
  description = "The name of the backend Lambda function"
  value       = aws_lambda_function.backend.function_name
}

output "function_arn" {
  description = "The ARN of the backend Lambda function"
  value       = aws_lambda_function.backend.arn
}
