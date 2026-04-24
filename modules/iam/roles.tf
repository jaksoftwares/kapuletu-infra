# Lambda Execution Role: Grants the backend Lambda permission to run and log to CloudWatch.
resource "aws_iam_role" "lambda_exec" {
  name = "kapuletu-${var.env}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# CI/CD Role (OIDC): Allows GitHub Actions to assume this role via OpenID Connect.
# This eliminates the need for long-lived AWS access keys in GitHub Secrets.
resource "aws_iam_role" "github_actions" {
  name = "kapuletu-${var.env}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com" # Replace with actual Account ID
      }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:YOUR_ORG/kapuletu-infra:*" # Restrict to your repository
        }
      }
    }]
  })
}

# Policy Attachment: In production, this should be scoped down to specific resources.
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Recommendation: Use a custom least-privilege policy
}
