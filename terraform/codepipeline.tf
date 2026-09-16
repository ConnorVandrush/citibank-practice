# ============================================================
# Login Pipeline
# ============================================================

resource "aws_codepipeline" "login" {
  name     = "citibank-practice-login-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "GitHub"

      push {
        branches {
          includes = ["main"]
        }

        file_paths {
          includes = [
            "citibank-practice-backend/login/**"
          ]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ConnorVandrush/citibank-practice"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name     = "TestLogin"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.login_test.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "BuildLoginImage"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.login.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "DeployLoginToECS"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.login.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "citibank-practice-login-pipeline"
  }
}


# ============================================================
# Employees Pipeline
# ============================================================

resource "aws_codepipeline" "employees" {
  name     = "citibank-practice-employees-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "GitHub"

      push {
        branches {
          includes = ["main"]
        }

        file_paths {
          includes = [
            "citibank-practice-backend/employees/**"
          ]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ConnorVandrush/citibank-practice"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name     = "TestEmployees"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.employees_test.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "BuildEmployeesImage"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.employees.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "DeployEmployeesToECS"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.employees.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "citibank-practice-employees-pipeline"
  }
}


# ============================================================
# Managers Pipeline
# ============================================================

resource "aws_codepipeline" "managers" {
  name     = "citibank-practice-managers-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "GitHub"

      push {
        branches {
          includes = ["main"]
        }

        file_paths {
          includes = [
            "citibank-practice-backend/managers/**"
          ]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ConnorVandrush/citibank-practice"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name     = "TestManagers"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.managers_test.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "BuildManagersImage"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.managers.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "DeployManagersToECS"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.managers.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "citibank-practice-managers-pipeline"
  }
}


# ============================================================
# Finance Administrator Pipeline
# ============================================================

resource "aws_codepipeline" "finance_admin" {
  name     = "citibank-practice-finance-admin-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "GitHub"

      push {
        branches {
          includes = ["main"]
        }

        file_paths {
          includes = [
            "citibank-practice-backend/finance-admins/**"
          ]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ConnorVandrush/citibank-practice"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name     = "TestFinanceAdmin"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.finance_admin_test.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "BuildFinanceAdminImage"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.finance_admin.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "DeployFinanceAdminToECS"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.finance_admin.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "citibank-practice-finance-admin-pipeline"
  }
}


# ============================================================
# Frontend Pipeline
#
# GitHub
#   ↓
# CodeBuild
#   ↓
# npm ci
#   ↓
# npm run build
#   ↓
# S3
#   ↓
# CloudFront invalidation
# ============================================================

resource "aws_codepipeline" "frontend" {
  name     = "citibank-practice-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  # ==========================================================
  # Trigger only when frontend files change on main
  # ==========================================================

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "GitHub"

      push {
        branches {
          includes = ["main"]
        }

        file_paths {
          includes = [
            "citibank-practice-frontend/**"
          ]
        }
      }
    }
  }

  # ==========================================================
  # Source
  # ==========================================================

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ConnorVandrush/citibank-practice"
        BranchName       = "main"
      }
    }
  }

  # ==========================================================
  # Build + Deploy
  #
  # The buildspec performs:
  # npm ci
  # npm run build
  # aws s3 sync
  # aws cloudfront create-invalidation
  # ==========================================================

  stage {
    name = "Build"

    action {
      name     = "BuildAndDeployFrontend"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }

  tags = {
    Name = "citibank-practice-frontend-pipeline"
  }
}


# ============================================================
# Outputs
# ============================================================

output "codebuild_login_project_name" {
  description = "CodeBuild project used to build the Login Docker image"
  value       = aws_codebuild_project.login.name
}

output "codebuild_employees_project_name" {
  description = "CodeBuild project used to build the Employees Docker image"
  value       = aws_codebuild_project.employees.name
}

output "codebuild_managers_project_name" {
  description = "CodeBuild project used to build the Managers Docker image"
  value       = aws_codebuild_project.managers.name
}

output "codebuild_finance_admin_project_name" {
  description = "CodeBuild project used to build the Finance Administrator Docker image"
  value       = aws_codebuild_project.finance_admin.name
}

output "codebuild_frontend_project_name" {
  description = "CodeBuild project used to build and deploy the frontend"
  value       = aws_codebuild_project.frontend.name
}


output "codepipeline_login_name" {
  description = "CodePipeline used to deploy the Login service"
  value       = aws_codepipeline.login.name
}

output "codepipeline_employees_name" {
  description = "CodePipeline used to deploy the Employees service"
  value       = aws_codepipeline.employees.name
}

output "codepipeline_managers_name" {
  description = "CodePipeline used to deploy the Managers service"
  value       = aws_codepipeline.managers.name
}

output "codepipeline_finance_admin_name" {
  description = "CodePipeline used to deploy the Finance Administrator service"
  value       = aws_codepipeline.finance_admin.name
}

output "codepipeline_frontend_name" {
  description = "CodePipeline used to build and deploy the frontend"
  value       = aws_codepipeline.frontend.name
}


output "codepipeline_artifact_bucket" {
  description = "S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}