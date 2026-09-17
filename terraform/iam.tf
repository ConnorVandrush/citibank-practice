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
# from AWS Secrets Manager when starting containers.
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
#
# Used by the Employees application itself.
# Allows IAM authentication to PostgreSQL.
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
#
# Used by the Managers application itself.
# Allows IAM authentication to PostgreSQL.
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
#
# Used by the Finance Administrator application itself.
# Allows IAM authentication to PostgreSQL.
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
# FRONTEND CODEBUILD ROLE
#
# Used by CodeBuild to:
# - Build the React/frontend application
# - Read CodePipeline artifacts
# - Upload frontend files to S3
# - Delete old frontend files from S3
# - Invalidate the CloudFront cache
# =========================================================

resource "aws_iam_role" "codebuild_frontend" {
  name = "citibank-practice-codebuild-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "citibank-practice-codebuild-frontend-role"
  }
}


resource "aws_iam_role_policy" "codebuild_frontend" {
  name = "citibank-practice-codebuild-frontend-policy"

  role = aws_iam_role.codebuild_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # -----------------------------------------------------
      # CloudWatch Logs
      # -----------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },


      # -----------------------------------------------------
      # CodePipeline Artifact Bucket
      #
      # CodeBuild receives the source artifact through
      # CodePipeline, so it needs access to the artifact
      # bucket.
      # -----------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
        ]
      },


      # -----------------------------------------------------
      # Frontend S3 Bucket
      #
      # Used by:
      # aws s3 sync dist/ s3://citibank-practice-frontend/
      # -----------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.frontend.arn
      },


      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },


      # -----------------------------------------------------
      # CloudFront
      #
      # Used by:
      # aws cloudfront create-invalidation
      # -----------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "cloudfront:CreateInvalidation"
        ]

        Resource = aws_cloudfront_distribution.frontend.arn
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

output "codebuild_frontend_role_arn" {
  description = "Frontend CodeBuild IAM role ARN"
  value       = aws_iam_role.codebuild_frontend.arn
}

# ============================================================
# Backend CodeBuild IAM Role
#
# Used by the Login, Employees, Managers, and Finance
# Administrator Docker builds.
# ============================================================

resource "aws_iam_role" "codebuild" {
  name = "citibank-practice-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codebuild.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "citibank-practice-codebuild-role"
  }
}

# ============================================================
# Backend CodeBuild Permissions
# ============================================================

resource "aws_iam_role_policy" "codebuild" {
  name = "citibank-practice-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ======================================================
      # CloudWatch Logs
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },

      # ======================================================
      # ECR Authentication
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      # ======================================================
      # ECR - Login
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeImages"
        ]

        Resource = aws_ecr_repository.login.arn
      },

      # ======================================================
      # ECR - Employees
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeImages"
        ]

        Resource = aws_ecr_repository.employees.arn
      },

      # ======================================================
      # ECR - Managers
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeImages"
        ]

        Resource = aws_ecr_repository.managers.arn
      },

      # ======================================================
      # ECR - Finance Administrator
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeImages"
        ]

        Resource = aws_ecr_repository.finance_admin.arn
      },

      # ======================================================
      # CodePipeline Artifact Bucket
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]

        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
        ]
      }
    ]
  })
}

# ============================================================
# CodePipeline IAM Role
# ============================================================

resource "aws_iam_role" "codepipeline" {
  name = "citibank-practice-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codepipeline.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "citibank-practice-codepipeline-role"
  }
}

# ============================================================
# CodePipeline Permissions
# ============================================================

resource "aws_iam_role_policy" "codepipeline" {
  name = "citibank-practice-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ======================================================
      # S3 - Artifact Bucket
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "s3:GetBucketVersioning"
        ]

        Resource = aws_s3_bucket.codepipeline_artifacts.arn
      },

      # ======================================================
      # S3 - Artifacts
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:PutObjectAcl"
        ]

        Resource = "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
      },

      # ======================================================
      # CodeBuild - Login
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.login.arn,
          aws_codebuild_project.login_test.arn
        ]
      },

      # ======================================================
      # CodeBuild - Employees
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.employees.arn,
          aws_codebuild_project.employees_test.arn
        ]
      },

      # ======================================================
      # CodeBuild - Managers
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.managers.arn,
          aws_codebuild_project.managers_test.arn
        ]
      },

      # ======================================================
      # CodeBuild - Finance Administrator
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.finance_admin.arn,
          aws_codebuild_project.finance_admin_test.arn
        ]
      },

      # ======================================================
      # CodeBuild - Frontend
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.frontend.arn,
          aws_codebuild_project.frontend_test.arn
        ]
      },

      # ======================================================
      # GitHub CodeConnections
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "codeconnections:UseConnection",
          "codestar-connections:UseConnection"
        ]

        Resource = var.github_connection_arn
      },

      # ======================================================
      # ECS Deployment
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeClusters",
          "ecs:TagResource"
        ]

        Resource = "*"
      },

      # ======================================================
      # IAM PassRole
      # ======================================================

      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = [
          aws_iam_role.ecs_execution.arn,
          aws_iam_role.login_task.arn,
          aws_iam_role.employees_task.arn,
          aws_iam_role.managers_task.arn,
          aws_iam_role.finance_admin_task.arn
        ]
      }
    ]
  })
}
