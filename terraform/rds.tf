resource "aws_db_subnet_group" "postgres" {
  name = "citibank-practice-postgres-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "citibank-practice-postgres-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "citibank-practice-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "expenses"
  username = "postgres"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  port = 5432

  publicly_accessible = false

  iam_database_authentication_enabled = true

  backup_retention_period = 1
  skip_final_snapshot     = true

  deletion_protection = false

  tags = {
    Name = "citibank-practice-postgres"
  }
}