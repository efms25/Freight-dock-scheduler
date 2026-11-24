
# =============================================================================
# ssm.tf — SSM Parameter Store
# =============================================================================

resource "aws_ssm_parameter" "database_url" {
  name        = "/${var.environment}/freight-dock-scheduler/DATABASE_URL"
  description = "Connection string do banco de dados PostgreSQL"
  type        = "SecureString"
  value       = var.ssm_database_url

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "s3_region" {
  name        = "/${var.environment}/freight-dock-scheduler/AWS_S3_REGION"
  description = "Região AWS do bucket S3"
  type        = "String"
  value       = var.ssm_s3_region

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "scheduling_bucket" {
  name        = "/${var.environment}/freight-dock-scheduler/SCHEDULING_BUCKET"
  description = "Nome do bucket S3 para agendamentos"
  type        = "String"
  value       = aws_s3_bucket.fds_docs.bucket

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
