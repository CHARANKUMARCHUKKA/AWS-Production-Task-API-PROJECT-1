resource "aws_ecs_service" "api" {
  count = var.enable_ecs_service ? 1 : 0

  name            = "${var.project_name}-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]
    security_groups  = [aws_security_group.api.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api[0].arn
    container_name   = "api"
    container_port   = 8000
  }

  health_check_grace_period_seconds  = 60
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    precondition {
      condition     = var.acm_certificate_arn != null
      error_message = "Set acm_certificate_arn before enabling the ECS service so it is never exposed over plain HTTP."
    }

    precondition {
      condition     = local.database_host != null && local.database_credentials_secret_arn != null
      error_message = "Set database_host and database_credentials_secret_arn (or enable managed RDS and database secrets) before enabling the ECS service."
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.environment}-api"
    Component = "ecs-service"
  }
}
