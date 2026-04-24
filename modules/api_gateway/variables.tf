variable "env" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "user_pool_arn" {
  type = string
}

variable "user_pool_endpoint" {
  type    = string
  default = "cognito-idp.us-east-1.amazonaws.com/us-east-1_example"
}
