resource "random_password" "jwt" {
  length  = 48
  special = true
}

resource "aws_secretsmanager_secret" "jwt" {
  name = "citibank-practice/jwt-secret"

  tags = {
    Name = "citibank-practice-jwt-secret"
  }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id = aws_secretsmanager_secret.jwt.id

  secret_string = random_password.jwt.result
}