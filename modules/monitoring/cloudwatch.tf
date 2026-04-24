# CloudWatch Log Group: Centralized logging for application resources.
# All Lambda and API Gateway logs should be directed here.
resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/kapuletu/${var.env}"
}
