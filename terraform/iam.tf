# =========================================================
# ECS Task Execution Role
#
# Used by ECS/Fargate itself to:
# - Pull images from ECR
# - Send container logs to CloudWatch
# =========================================================

resource "aws_iam_role" "ecs_execution" {
  name = "citibank-practice-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-ecs-execution-role"
  }
}


resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# =========================================================
# ECS Execution Role - Secrets Manager
#
# Allows ECS/Fargate to retrieve the JWT secret
# from AWS Secrets Manager when starting the container.
# =========================================================

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "citibank-practice-ecs-execution-secrets"

  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.jwt.arn
      }
    ]
  })
}


# =========================================================
# Login Task Role
#
# Used by the Login application itself.
# Allows IAM authentication to PostgreSQL.
# =========================================================

resource "aws_iam_role" "login_task" {
  name = "citibank-practice-login-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-login-task-role"
  }
}


resource "aws_iam_role_policy" "login_rds" {
  name = "citibank-practice-login-rds-connect"

  role = aws_iam_role.login_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "rds-db:connect"
        ]

        Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/postgres"
      }
    ]
  })
}


# =========================================================
# Employees Task Role
# =========================================================

resource "aws_iam_role" "employees_task" {
  name = "citibank-practice-employees-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-employees-task-role"
  }
}


resource "aws_iam_role_policy" "employees_rds" {
  name = "citibank-practice-employees-rds-connect"

  role = aws_iam_role.employees_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "rds-db:connect"
        ]

        Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/postgres"
      }
    ]
  })
}


# =========================================================
# Managers Task Role
# =========================================================

resource "aws_iam_role" "managers_task" {
  name = "citibank-practice-managers-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-managers-task-role"
  }
}


resource "aws_iam_role_policy" "managers_rds" {
  name = "citibank-practice-managers-rds-connect"

  role = aws_iam_role.managers_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "rds-db:connect"
        ]

        Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/postgres"
      }
    ]
  })
}


# =========================================================
# Finance Administrator Task Role
# =========================================================

resource "aws_iam_role" "finance_admin_task" {
  name = "citibank-practice-finance-admin-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-finance-admin-task-role"
  }
}


resource "aws_iam_role_policy" "finance_admin_rds" {
  name = "citibank-practice-finance-admin-rds-connect"

  role = aws_iam_role.finance_admin_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "rds-db:connect"
        ]

        Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/postgres"
      }
    ]
  })
}


# =========================================================
# AWS Account Identity
#
# Used to construct the RDS IAM authentication ARN.
# =========================================================

data "aws_caller_identity" "current" {}


# =========================================================
# Outputs
# =========================================================

output "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_execution.arn
}

output "login_task_role_arn" {
  description = "Login ECS task role ARN"
  value       = aws_iam_role.login_task.arn
}

output "employees_task_role_arn" {
  description = "Employees ECS task role ARN"
  value       = aws_iam_role.employees_task.arn
}

output "managers_task_role_arn" {
  description = "Managers ECS task role ARN"
  value       = aws_iam_role.managers_task.arn
}

output "finance_admin_task_role_arn" {
  description = "Finance Administrator ECS task role ARN"
  value       = aws_iam_role.finance_admin_task.arn
}