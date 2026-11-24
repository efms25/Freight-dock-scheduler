
# =============================================================================
# ecr.tf — ECR Repositories
# =============================================================================

resource "aws_ecr_repository" "app" {
  name                 = "${var.environment}/freight-dock-scheduler"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}/freight-dock-scheduler"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "migrate" {
  name                 = "${var.environment}/freight-dock-scheduler-migrate"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}/freight-dock-scheduler-migrate"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Lifecycle policy: mantém apenas as últimas 10 imagens
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "migrate" {
  repository = aws_ecr_repository.migrate.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
