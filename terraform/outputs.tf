
# =============================================================================
# outputs.tf — Outputs úteis após o apply
# =============================================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS do Application Load Balancer (URL de acesso à aplicação)"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.main.arn
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.app.name
}

output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_identifier" {
  description = "Identificador da instância RDS"
  value       = aws_db_instance.main.identifier
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.fds_docs.bucket
}

output "ecr_app_repository_url" {
  description = "URL do repositório ECR da aplicação"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_migrate_repository_url" {
  description = "URL do repositório ECR de migração"
  value       = aws_ecr_repository.migrate.repository_url
}

output "ssm_database_url_arn" {
  description = "ARN do parâmetro SSM com a DATABASE_URL"
  value       = aws_ssm_parameter.database_url.arn
}
