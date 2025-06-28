output "db_instance_address" {
  description = "The connection endpoint for the RDS instance"
  value       = module.db.db_instance_address
}

output "rds_security_group_id" {
  description = "The security group ID used by RDS"
  value       = aws_security_group.rds.id
}
