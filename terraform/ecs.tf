
# =============================================================================
# ecs.tf — ECS Cluster, Task Definitions e Service
# =============================================================================

# ---- CloudWatch Log Group ----
resource "aws_cloudwatch_log_group" "fds" {
  name              = "/fds"
  retention_in_days = 30

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- ECS Cluster ----
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.project_name}"

  setting {
    name  = "containerInsights"
    value = "disabled"  # Mude para "enabled" em produção
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}

# ---- Task Definition: Aplicação ----
resource "aws_ecs_task_definition" "app" {
  family                   = "fds-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "fds-app"
    image     = var.app_image_uri
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
      name          = "fds-app-8080-tcp"
      appProtocol   = "http"
    }]

    environment = [
      { name = "NODE_ENV", value = "production" }
    ]

    secrets = [
      {
        name      = "DATABASE_URL"
        valueFrom = aws_ssm_parameter.database_url.arn
      },
      {
        name      = "AWS_S3_REGION"
        valueFrom = aws_ssm_parameter.s3_region.arn
      },
      {
        name      = "SCHEDULING_BUCKET"
        valueFrom = aws_ssm_parameter.scheduling_bucket.arn
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.fds.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])

  tags = {
    Name        = "fds-app"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- Task Definition: Migration ----
resource "aws_ecs_task_definition" "migration" {
  family                   = "FDS-migration"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "migration"
    image     = var.migration_image_uri
    essential = true

    environment = [
      { name = "NODE_ENV", value = "production" }
    ]

    secrets = [
      {
        name      = "DATABASE_URL"
        valueFrom = aws_ssm_parameter.database_url.arn
      },
      {
        name      = "AWS_S3_REGION"
        valueFrom = aws_ssm_parameter.s3_region.arn
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.fds.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])

  tags = {
    Name        = "FDS-migration"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- ECS Service ----
resource "aws_ecs_service" "app" {
  name            = "fds-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "fds-app"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  # Garante que o ALB e o target group existam antes do serviço
  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution_policy
  ]

  tags = {
    Name        = "fds-app-service"
    Project     = var.project_name
    Environment = var.environment
  }
}
