resource "aws_ecr_repository" "login" {
  name                 = "citibank-practice-backend-login"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "citibank-practice-backend-login"
  }
}

resource "aws_ecr_repository" "employees" {
  name                 = "citibank-practice-backend-employees"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "citibank-practice-backend-employees"
  }
}

resource "aws_ecr_repository" "managers" {
  name                 = "citibank-practice-backend-managers"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "citibank-practice-backend-managers"
  }
}

resource "aws_ecr_repository" "finance_admin" {
  name                 = "citibank-practice-backend-finance-admin"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "citibank-practice-backend-finance-admin"
  }
}