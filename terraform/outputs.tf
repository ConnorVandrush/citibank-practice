output "aws_region" {
  description = "AWS region being used"
  value       = var.aws_region
}

output "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "postgres_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "postgres_db_name" {
  description = "RDS PostgreSQL database name"
  value       = aws_db_instance.postgres.db_name
}