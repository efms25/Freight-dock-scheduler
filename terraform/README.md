
# FDS — Freight Dock Scheduler — Terraform IaC

## Estrutura dos arquivos

| Arquivo              | Descrição                                              |
|----------------------|--------------------------------------------------------|
| `main.tf`            | Provider AWS e configuração do Terraform               |
| `variables.tf`       | Declaração de todas as variáveis                       |
| `terraform.tfvars`   | Valores das variáveis (não commitar senhas)            |
| `vpc.tf`             | VPC, subnets, IGW, route tables, VPC Endpoints         |
| `security_groups.tf` | Security Groups (ALB, ECS, RDS)                        |
| `iam.tf`             | IAM Roles e Policies (execution role + task role)      |
| `s3.tf`              | Bucket S3 para documentos                              |
| `rds.tf`             | RDS PostgreSQL 18.3                                    |
| `ssm.tf`             | SSM Parameter Store (DATABASE_URL, S3_REGION, BUCKET)  |
| `ecr.tf`             | ECR Repositories (app + migrate)                       |
| `alb.tf`             | Application Load Balancer, Target Group, Listener      |
| `ecs.tf`             | ECS Cluster, Task Definitions (app + migration), Service|
| `outputs.tf`         | Outputs úteis após o apply                             |

## Pré-requisitos

- Terraform >= 1.5.0
- AWS CLI configurado com permissões adequadas
- Imagens Docker já publicadas no ECR (ou use o ECR criado pelo Terraform)

## Como usar

### 1. Configurar variáveis sensíveis via variáveis de ambiente (recomendado)

```bash
export TF_VAR_db_password="sua_senha_segura"
export TF_VAR_ssm_database_url="postgresql://postgres:senha@endpoint:5432/freight_dock_scheduler"
```

### 2. Inicializar o Terraform

```bash
terraform init
```

### 3. Revisar o plano

```bash
terraform plan
```

### 4. Aplicar a infraestrutura

```bash
terraform apply
```

### 5. Executar a migration (após o apply)

```bash
# Obter IDs das subnets e SG privados
SUBNET_1=$(terraform output -raw private_subnet_ids | cut -d',' -f1 | tr -d ' "[]')
SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=poc-FDS-ecs-tasks-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

# Executar task de migration
aws ecs run-task \
  --cluster poc-FDS \
  --task-definition FDS-migration \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_1],securityGroups=[$SG],assignPublicIp=DISABLED}"
```

### 6. Acessar a aplicação

```bash
terraform output alb_dns_name
```

## Ordem de criação dos recursos

O Terraform resolve as dependências automaticamente, mas a ordem lógica é:

1. VPC + Subnets + IGW + Route Tables
2. Security Groups
3. VPC Endpoints (ECR, SSM, S3, CloudWatch Logs)
4. IAM Roles
5. S3 Bucket
6. RDS PostgreSQL
7. SSM Parameters
8. ECR Repositories
9. ALB + Target Group + Listener
10. ECS Cluster + Task Definitions
11. ECS Service (migration deve ser executada manualmente após o RDS estar disponível)

## Destruir a infraestrutura

```bash
terraform destroy
```

> ⚠️ Atenção: isso removerá todos os recursos, incluindo o banco de dados RDS e os dados no S3.
