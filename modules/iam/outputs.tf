# Exported values for authorization and resource execution.
output "lambda_role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_exec.arn
}

output "github_actions_role_arn" {
  description = "The ARN of the OIDC role for CI/CD"
  value       = aws_iam_role.github_actions.arn
}
