# Exported values for the QLDB ledger.
output "ledger_name" {
  description = "The name of the QLDB ledger"
  value       = aws_qldb_ledger.main.name
}

output "ledger_arn" {
  description = "The ARN of the QLDB ledger"
  value       = aws_qldb_ledger.main.arn
}
