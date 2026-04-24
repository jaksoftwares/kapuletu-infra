# Exported values for object storage.
output "bucket_name" {
  description = "The name of the assets S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the assets S3 bucket"
  value       = aws_s3_bucket.main.arn
}
