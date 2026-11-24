
# =============================================================================
# FDS - Freight Dock Scheduler — Infraestrutura Completa em Terraform
# Gerado a partir do ambiente poc-FDS em us-east-1
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Descomente e configure para usar backend remoto (recomendado para produção)
  # backend "s3" {
  #   bucket = "meu-terraform-state"
  #   key    = "fds/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
