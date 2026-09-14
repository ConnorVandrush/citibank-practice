# ============================================================
# ECS Cluster
# ============================================================

resource "aws_ecs_cluster" "main" {
  name = "citibank-practice-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "citibank-practice-cluster"
  }
}


# ============================================================
# CloudWatch Log Groups
# ============================================================

resource "aws_cloudwatch_log_group" "login" {
  name              = "/ecs/citibank-practice-login"
  retention_in_days = 7

  tags = {
    Name = "citibank-practice-login-logs"
  }
}

resource "aws_cloudwatch_log_group" "employees" {
  name              = "/ecs/citibank-practice-employees"
  retention_in_days = 7

  tags = {
    Name = "citibank-practice-employees-logs"
  }
}

resource "aws_cloudwatch_log_group" "managers" {
  name              = "/ecs/citibank-practice-managers"
  retention_in_days = 7

  tags = {
    Name = "citibank-practice-managers-logs"
  }
}

resource "aws_cloudwatch_log_group" "finance_admin" {
  name              = "/ecs/citibank-practice-finance-admin"
  retention_in_days = 7

  tags = {
    Name = "citibank-practice-finance-admin-logs"
  }
}


# ============================================================
# Outputs
# ============================================================

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}