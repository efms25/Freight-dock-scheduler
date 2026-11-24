
# =============================================================================
# rds.tf — RDS PostgreSQL
# =============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "${var.environment}-${var.project_name}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-freight-dock-scheduler"
  engine            = "postgres"
  engine_version    = "18.3"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true   # Mude para false em produção
  deletion_protection    = false  # Mude para true em produção
  backup_retention_period = 7     # dias

  # Habilita IAM authentication
  iam_database_authentication_enabled = true

  tags = {
    Name        = "${var.environment}-freight-dock-scheduler"
    Project     = var.project_name
    Environment = var.environment
  }
}
