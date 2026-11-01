locals {
  # ALB and target group names are limited to 32 characters by AWS.
  api_load_balancer_name = substr("${var.project_name}-${var.environment}-api", 0, 32)

  # Resolved database host: explicit override takes precedence, followed by managed RDS instance.
  database_host = var.database_host != null ? var.database_host : (
    var.enable_rds ? try(aws_db_instance.main[0].address, null) : null
  )

  # Resolved Secrets Manager ARN: explicit override takes precedence, followed by managed secret.
  database_credentials_secret_arn = var.database_credentials_secret_arn != null ? var.database_credentials_secret_arn : (
    var.enable_database_secrets ? try(aws_secretsmanager_secret.database_credentials[0].arn, null) : null
  )
}

