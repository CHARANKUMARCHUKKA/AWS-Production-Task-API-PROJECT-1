output "vpc_id" {
  description = "ID of the project VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private database subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "alb_security_group_id" {
  description = "Security group ID for the load balancer."
  value       = aws_security_group.alb.id
}

output "api_security_group_id" {
  description = "Security group ID for the API."
  value       = aws_security_group.api.id
}

output "database_security_group_id" {
  description = "Security group ID for the database."
  value       = aws_security_group.database.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the API image."
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "api_load_balancer_dns_name" {
  description = "Public DNS name of the API ALB when the ECS service is enabled."
  value       = try(aws_lb.api[0].dns_name, null)
}

output "database_endpoint" {
  description = "Connection endpoint of the RDS MySQL instance."
  value       = try(aws_db_instance.main[0].endpoint, null)
}

output "database_credentials_secret_arn" {
  description = "Secrets Manager ARN holding database credentials."
  value       = local.database_credentials_secret_arn
  sensitive   = true
}

output "migration_task_definition_arn" {
  description = "ARN of the Alembic migration task definition."
  value       = try(aws_ecs_task_definition.migration[0].arn, null)
}
