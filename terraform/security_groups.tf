
# =============================================================================
# security_groups.tf — Security Groups
# =============================================================================

# ---- ALB Security Group ----
resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.project_name}-alb-sg"
  description = "Application load balancer security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "public HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Allow to ECS tasks on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- ECS Tasks Security Group ----
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-${var.project_name}-ecs-tasks-sg"
  description = "ECS tasks for ${var.project_name} cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow from ALB on app port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Allow internal HTTPS (VPC Endpoints)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow SSM parameter fetch and ECR pull"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-ecs-tasks-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- RDS Security Group ----
resource "aws_security_group" "rds" {
  name        = "${var.environment}-${var.project_name}-rds-sg"
  description = "RDS PostgreSQL access for ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}
