# QLDB Ledger: Provides an immutable, cryptographically verifiable transaction log.
# Essential for fintech applications to ensure data integrity and auditability.
resource "aws_qldb_ledger" "main" {
  name             = "kapuletu-${var.env}-ledger"
  permissions_mode = "ALLOW_ALL" # Standard mode for ledger permissions
  deletion_protection = false   # Set to true for Production to prevent accidental deletion

  tags = {
    Env = var.env
  }
}

variable "env" {
  description = "Environment name"
  type        = string
}
