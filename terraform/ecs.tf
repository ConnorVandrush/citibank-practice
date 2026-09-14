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
# Login Task Definition
# ============================================================

resource "aws_ecs_task_definition" "login" {
  family                   = "citibank-practice-login"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.login_task.arn

  container_definitions = jsonencode([
    {
      name      = "login"
      image     = "${aws_ecr_repository.login.repository_url}:cce841a9239dd4f38d9e484cc746f4579e958882"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name  = "DB_USER"
          value = "postgres"
        }
      ]

      secrets = [
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.login.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "citibank-practice-login-task"
  }
}


resource "aws_ecs_service" "login" {
  name            = "citibank-practice-login"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.login.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.login.arn
    container_name   = "login"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.backend
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "citibank-practice-login-service"
  }
}


# ============================================================
# Employees Task Definition
# ============================================================

resource "aws_ecs_task_definition" "employees" {
  family                   = "citibank-practice-employees"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.employees_task.arn

  container_definitions = jsonencode([
    {
      name      = "employees"
      image     = "${aws_ecr_repository.employees.repository_url}:bootstrap"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name  = "DB_USER"
          value = "postgres"
        }
      ]

      secrets = [
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.employees.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "citibank-practice-employees-task"
  }
}


resource "aws_ecs_service" "employees" {
  name            = "citibank-practice-employees"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.employees.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.employees.arn
    container_name   = "employees"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.backend
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "citibank-practice-employees-service"
  }
}


# ============================================================
# Managers Task Definition
# ============================================================

resource "aws_ecs_task_definition" "managers" {
  family                   = "citibank-practice-managers"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.managers_task.arn

  container_definitions = jsonencode([
    {
      name      = "managers"
      image     = "${aws_ecr_repository.managers.repository_url}:bootstrap"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name  = "DB_USER"
          value = "postgres"
        }
      ]

      secrets = [
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.managers.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "citibank-practice-managers-task"
  }
}


resource "aws_ecs_service" "managers" {
  name            = "citibank-practice-managers"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.managers.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.managers.arn
    container_name   = "managers"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.backend
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "citibank-practice-managers-service"
  }
}


# ============================================================
# Finance Admin Task Definition
# ============================================================

resource "aws_ecs_task_definition" "finance_admin" {
  family                   = "citibank-practice-finance-admin"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.finance_admin_task.arn

  container_definitions = jsonencode([
    {
      name      = "finance-admin"
      image     = "${aws_ecr_repository.finance_admin.repository_url}:bootstrap"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name  = "DB_USER"
          value = "postgres"
        }
      ]

      secrets = [
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.finance_admin.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "citibank-practice-finance-admin-task"
  }
}


resource "aws_ecs_service" "finance_admin" {
  name            = "citibank-practice-finance-admin"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.finance_admin.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.finance_admin.arn
    container_name   = "finance-admin"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.backend
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "citibank-practice-finance-admin-service"
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