resource "aws_security_group" "alb" {
  name        = "citibank-practice-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citibank-practice-alb-sg"
  }
}

resource "aws_security_group" "ecs" {
  name        = "citibank-practice-ecs-sg"
  description = "Security group for ECS Fargate services"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from the application load balancer"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citibank-practice-ecs-sg"
  }
}

resource "aws_security_group" "postgres" {
  name        = "citibank-practice-postgres-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citibank-practice-postgres-sg"
  }
}

resource "aws_security_group" "cloudshell" {
  name        = "citibank-practice-cloudshell"
  description = "Security group for CloudShell database administration"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citibank-practice-cloudshell"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_cloudshell" {
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = aws_security_group.cloudshell.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow CloudShell to connect to PostgreSQL"
}