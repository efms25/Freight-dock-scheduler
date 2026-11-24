
# =============================================================================
# variables.tf
# =============================================================================

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (prefixo para todos os recursos)"
  type        = string
  default     = "FDS"
}

variable "environment" {
  description = "Ambiente (poc, dev, staging, prod)"
  type        = string
  default     = "poc"
}

# ---- VPC ----
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.10.0.0/20", "10.10.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.10.128.0/20", "10.10.144.0/20"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ---- RDS ----
variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "freight_dock_scheduler"
}

variable "db_username" {
  description = "Usuário master do banco de dados"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Senha master do banco de dados (use AWS Secrets Manager em produção)"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o RDS (GB)"
  type        = number
  default     = 20
}

# ---- ECS ----
variable "app_image_uri" {
  description = "URI da imagem Docker da aplicação no ECR"
  type        = string
  # Exemplo: 123456789012.dkr.ecr.us-east-1.amazonaws.com/poc/freight-dock-scheduler:latest
}

variable "migration_image_uri" {
  description = "URI da imagem Docker de migração no ECR"
  type        = string
  # Exemplo: 123456789012.dkr.ecr.us-east-1.amazonaws.com/poc/freight-dock-scheduler-migrate:latest
}

variable "app_cpu" {
  description = "CPU para a task ECS da aplicação (unidades)"
  type        = number
  default     = 512
}

variable "app_memory" {
  description = "Memória para a task ECS da aplicação (MB)"
  type        = number
  default     = 1024
}

variable "app_desired_count" {
  description = "Número desejado de tasks ECS em execução"
  type        = number
  default     = 1
}

# ---- S3 ----
variable "s3_bucket_name" {
  description = "Nome do bucket S3 para documentos FDS"
  type        = string
  default     = "pocs.fds-docs"
}

# ---- SSM Parameters ----
variable "ssm_database_url" {
  description = "Connection string do banco de dados (armazenada no SSM)"
  type        = string
  sensitive   = true
}

variable "ssm_s3_region" {
  description = "Região do S3 (armazenada no SSM)"
  type        = string
  default     = "us-east-1"
}
