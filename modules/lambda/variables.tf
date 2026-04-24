# Input variables for the Lambda module.
variable "env" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role for Lambda execution"
  type        = string
}

variable "artifact_bucket" {
  description = "The S3 bucket containing the Lambda deployment package"
  type        = string
}

variable "artifact_key" {
  description = "The S3 key (path) to the Lambda deployment package"
  type        = string
}
