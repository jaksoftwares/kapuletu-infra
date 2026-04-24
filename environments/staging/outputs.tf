output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
