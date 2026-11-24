
# =============================================================================
# terraform.tfvars — Valores padrão (NÃO commitar com senhas reais)
# =============================================================================

aws_region   = "us-east-1"
project_name = "FDS"
environment  = "poc"

# VPC
vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.0.0/20", "10.10.16.0/20"]
private_subnet_cidrs = ["10.10.128.0/20", "10.10.144.0/20"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# RDS
db_instance_class    = "db.t4g.micro"
db_name              = "freight_dock_scheduler"
db_username          = "postgres"
db_password          = "SUBSTITUA_POR_SENHA_SEGURA"  # Use variável de ambiente TF_VAR_db_password
db_allocated_storage = 20

# ECS
app_cpu           = 512
app_memory        = 1024
app_desired_count = 1

# Imagens ECR — substitua pelo account ID e tag corretos
app_image_uri       = "SEU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/poc/freight-dock-scheduler:latest"
migration_image_uri = "SEU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/poc/freight-dock-scheduler-migrate:latest"

# S3
s3_bucket_name = "pocs.fds-docs"

# SSM — substitua pela connection string real
ssm_database_url = "postgresql://postgres:SENHA@SEU_RDS_ENDPOINT:5432/freight_dock_scheduler"
ssm_s3_region    = "us-east-1"
