resource "random_password" "database_password" {
  count = var.enable_database_secrets ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "database_credentials" {
  count = var.enable_database_secrets ? 1 : 0

  name_prefix             = "${var.project_name}-${var.environment}-db-creds-"
  description             = "Database credentials for ${var.project_name} in ${var.environment}"
  recovery_window_in_days = 0

  tags = {
    Name      = "${var.project_name}-${var.environment}-db-credentials"
    Component = "secrets"
  }
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  count = var.enable_database_secrets ? 1 : 0

  secret_id = aws_secretsmanager_secret.database_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.database_password[0].result
  })
}
