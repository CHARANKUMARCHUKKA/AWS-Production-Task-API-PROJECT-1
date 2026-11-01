resource "aws_db_instance" "main" {
  count = var.enable_rds ? 1 : 0

  identifier            = "${var.project_name}-${var.environment}-db"
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 50
  storage_type          = "gp3"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  db_name  = var.database_name
  username = var.db_username
  password = var.enable_database_secrets ? random_password.database_password[0].result : null
  port     = var.database_port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  storage_encrypted = true
  multi_az          = false

  backup_retention_period     = 1
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  skip_final_snapshot = true
  deletion_protection = false

  lifecycle {
    precondition {
      condition     = var.enable_database_secrets || var.database_credentials_secret_arn != null
      error_message = "When enable_rds is true, either enable_database_secrets must be true or database_credentials_secret_arn must be provided."
    }
    ignore_changes = [
      password
    ]
  }

  tags = {
    Name      = "${var.project_name}-${var.environment}-mysql"
    Component = "database"
  }
}
