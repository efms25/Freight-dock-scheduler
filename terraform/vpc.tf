
# =============================================================================
# vpc.tf — VPC, Subnets, IGW, Route Tables, VPC Endpoints
# =============================================================================

# ---- VPC ----
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- Internet Gateway ----
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- Subnets Públicas ----
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # Subnets públicas NÃO atribuem IP público automaticamente (ALB usa ENIs)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${var.project_name}-subnet-public${count.index + 1}-${var.availability_zones[count.index]}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}

# ---- Subnets Privadas ----
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-${var.project_name}-subnet-private${count.index + 1}-${var.availability_zones[count.index]}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}

# ---- Route Table Pública ----
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-rtb-public"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---- Route Tables Privadas (uma por AZ) ----
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.project_name}-rtb-private${count.index + 1}-${var.availability_zones[count.index]}"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# =============================================================================
# VPC Endpoints — permite que tasks privadas acessem AWS APIs sem NAT Gateway
# =============================================================================

# ---- S3 Gateway Endpoint ----
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-s3"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- ECR API Interface Endpoint ----
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-ecr-api"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- ECR DKR Interface Endpoint ----
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-ecr-dkr"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- CloudWatch Logs Interface Endpoint ----
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- SSM Interface Endpoint ----
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-ssm"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---- SSM Messages Interface Endpoint ----
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-vpce-ssmmessages"
    Project     = var.project_name
    Environment = var.environment
  }
}
