resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  tags = {
    Name      = "${var.project_name}-${var.environment}"
    Component = "ecs"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-${var.environment}/api"
  retention_in_days = 7

  tags = {
    Name      = "${var.project_name}-${var.environment}-api"
    Component = "logging"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-execution"
    Component = "iam"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  count = var.enable_ecs_service ? 1 : 0

  name = "${var.project_name}-${var.environment}-read-database-credentials"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = local.database_credentials_secret_arn
    }]
  })
}

resource "aws_ecs_task_definition" "api" {
  count = var.enable_ecs_service ? 1 : 0

  family                   = "${var.project_name}-${var.environment}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  depends_on = [aws_iam_role_policy.ecs_task_execution_secrets]

  container_definitions = jsonencode([{
    name      = "api"
    image     = "${aws_ecr_repository.api.repository_url}:${var.container_image_tag}"
    essential = true

    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "api"
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
    Name      = "${var.project_name}-${var.environment}-api"
    Component = "ecs-task"
  }
}
