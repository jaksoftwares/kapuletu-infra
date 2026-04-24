resource "aws_s3_bucket" "main" {
  bucket = "kapuletu-${var.env}-assets"

  tags = {
    Env = var.env
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

variable "env" {
  type = string
}
