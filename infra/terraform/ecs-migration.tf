resource "aws_ecs_task_definition" "migration" {
  count = var.enable_ecs_service ? 1 : 0

  family                   = "${var.project_name}-${var.environment}-migration"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  depends_on = [aws_iam_role_policy.ecs_task_execution_secrets]

  container_definitions = jsonencode([{
    name      = "migration"
    image     = "${aws_ecr_repository.api.repository_url}:${var.container_image_tag}"
    essential = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "migration"
      }
    }

    environment = [
      { name = "MYSQL_DATABASE", value = var.database_name },
      { name = "MYSQL_HOST", value = local.database_host },
      { name = "MYSQL_PORT", value = tostring(var.database_port) }
    ]

    secrets = [
      { name = "MYSQL_USER", valueFrom = "${local.database_credentials_secret_arn}:username::" },
      { name = "MYSQL_PASSWORD", valueFrom = "${local.database_credentials_secret_arn}:password::" }
    ]
  }])

  lifecycle {
    precondition {
      condition = !var.enable_ecs_service || (
        var.container_image_tag != "replace-with-immutable-image-tag" &&
        var.container_image_tag != "latest"
      )
      error_message = "Set container_image_tag to an immutable image tag before enabling the ECS service."
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.environment}-migration"
    Component = "ecs-migration-task"
  }
}
