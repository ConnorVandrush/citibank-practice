# ============================================================
# CodePipeline Artifact Bucket
# ============================================================

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "citibank-practice-codepipeline-artifacts"

  tags = {
    Name = "citibank-practice-codepipeline-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ============================================================
# CodeBuild IAM Role
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
# CodeBuild Permissions
# ============================================================

resource "aws_iam_role_policy" "codebuild" {
  name = "citibank-practice-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # CloudWatch Logs
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },

      # ECR
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = aws_ecr_repository.login.arn
      },

      # CodePipeline artifact bucket
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
# CodeBuild Project
# ============================================================

resource "aws_codebuild_project" "login" {
  name = "citibank-practice-login-build"

  description = "Build and push the Login service Docker image to ECR"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-backend/login/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-login"
      stream_name = "build"
    }
  }

  tags = {
    Name = "citibank-practice-login-build"
  }
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
      {
        Effect = "Allow"

        Action = [
          "s3:GetBucketVersioning"
        ]

        Resource = aws_s3_bucket.codepipeline_artifacts.arn
      },

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

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = aws_codebuild_project.login.arn
      },

      {
        Effect = "Allow"

        Action = [
          "codeconnections:UseConnection",
          "codestar-connections:UseConnection"
        ]

        Resource = var.github_connection_arn
      }
    ]
  })
}


# ============================================================
# CodePipeline
# ============================================================

resource "aws_codepipeline" "login" {
  name     = "citibank-practice-login-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
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
    name = "Build"

    action {
      name            = "BuildLoginImage"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"

      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.login.name
      }
    }
  }

  tags = {
    Name = "citibank-practice-login-pipeline"
  }
}


# ============================================================
# Outputs
# ============================================================

output "codebuild_login_project_name" {
  description = "CodeBuild project used to build the Login Docker image"
  value       = aws_codebuild_project.login.name
}

output "codepipeline_login_name" {
  description = "CodePipeline used to build the Login Docker image"
  value       = aws_codepipeline.login.name
}

output "codepipeline_artifact_bucket" {
  description = "S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}
