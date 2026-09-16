# ============================================================
# CodeBuild Project - Login
# ============================================================

resource "aws_codebuild_project" "login" {
  name = "citibank-practice-login-build"

  description = "Build and push the Login service Docker image to ECR"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

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
# CodeBuild Project - Employees
# ============================================================

resource "aws_codebuild_project" "employees" {
  name = "citibank-practice-employees-build"

  description = "Build and push the Employees service Docker image to ECR"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

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
    buildspec = "citibank-practice-backend/employees/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-employees"
      stream_name = "build"
    }
  }

  tags = {
    Name = "citibank-practice-employees-build"
  }
}


# ============================================================
# CodeBuild Project - Managers
# ============================================================

resource "aws_codebuild_project" "managers" {
  name = "citibank-practice-managers-build"

  description = "Build and push the Managers service Docker image to ECR"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

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
    buildspec = "citibank-practice-backend/managers/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-managers"
      stream_name = "build"
    }
  }

  tags = {
    Name = "citibank-practice-managers-build"
  }
}


# ============================================================
# CodeBuild Project - Finance Administrator
# ============================================================

resource "aws_codebuild_project" "finance_admin" {
  name = "citibank-practice-finance-admin-build"

  description = "Build and push the Finance Administrator service Docker image to ECR"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

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
    buildspec = "citibank-practice-backend/finance-admins/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-finance-admin"
      stream_name = "build"
    }
  }

  tags = {
    Name = "citibank-practice-finance-admin-build"
  }
}


# ============================================================
# CodeBuild Project - Frontend
#
# The frontend buildspec:
# - Installs dependencies
# - Builds the frontend
# - Uploads dist/ to S3
# - Invalidates CloudFront
# ============================================================

resource "aws_codebuild_project" "frontend" {
  name = "citibank-practice-frontend-build"

  description = "Build and deploy the frontend to S3 and CloudFront"

  service_role = aws_iam_role.codebuild_frontend.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-frontend/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-frontend"
      stream_name = "build"
    }
  }

  tags = {
    Name = "citibank-practice-frontend-build"
  }
}

# ============================================================
# CodeBuild Test Project - Login
# ============================================================

resource "aws_codebuild_project" "login_test" {
  name = "citibank-practice-login-test"

  description = "Run automated tests for the Login service"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-backend/login/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-login-test"
      stream_name = "test"
    }
  }

  tags = {
    Name = "citibank-practice-login-test"
  }
}

# ============================================================
# CodeBuild Test Project - Employees
# ============================================================

resource "aws_codebuild_project" "employees_test" {
  name = "citibank-practice-employees-test"

  description = "Run automated tests for the Employees service"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-backend/employees/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-employees-test"
      stream_name = "test"
    }
  }

  tags = {
    Name = "citibank-practice-employees-test"
  }
}

# ============================================================
# CodeBuild Test Project - Managers
# ============================================================

resource "aws_codebuild_project" "managers_test" {
  name = "citibank-practice-managers-test"

  description = "Run automated tests for the Managers service"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-backend/managers/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-managers-test"
      stream_name = "test"
    }
  }

  tags = {
    Name = "citibank-practice-managers-test"
  }
}

# ============================================================
# CodeBuild Test Project - Finance Administrator
# ============================================================

resource "aws_codebuild_project" "finance_admin_test" {
  name = "citibank-practice-finance-admin-test"

  description = "Run automated tests for the Finance Administrator service"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-backend/finance-admins/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-finance-admin-test"
      stream_name = "test"
    }
  }

  tags = {
    Name = "citibank-practice-finance-admin-test"
  }
}

resource "aws_codebuild_project" "frontend_test" {
  name        = "citibank-practice-frontend-test"
  description = "Run frontend tests"

  service_role = aws_iam_role.codebuild_frontend.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "citibank-practice-frontend/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/citibank-practice-frontend-test"
      stream_name = "test"
    }
  }

  tags = {
    Name = "citibank-practice-frontend-test"
  }
}