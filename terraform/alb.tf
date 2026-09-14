# =========================================================
# Application Load Balancer
# =========================================================

resource "aws_lb" "backend" {
  name               = "citibank-practice-backend-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "citibank-practice-backend-alb"
  }
}


# =========================================================
# Target Group: Login
# =========================================================

resource "aws_lb_target_group" "login" {
  name        = "citibank-login-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  tags = {
    Name = "citibank-login-tg"
  }
}


# =========================================================
# Target Group: Employees
# =========================================================

resource "aws_lb_target_group" "employees" {
  name        = "citibank-employees-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  tags = {
    Name = "citibank-employees-tg"
  }
}


# =========================================================
# Target Group: Managers
# =========================================================

resource "aws_lb_target_group" "managers" {
  name        = "citibank-managers-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  tags = {
    Name = "citibank-managers-tg"
  }
}


# =========================================================
# Target Group: Finance Administrator
# =========================================================

resource "aws_lb_target_group" "finance_admin" {
  name        = "citibank-finance-admin-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  tags = {
    Name = "citibank-finance-admin-tg"
  }
}


# =========================================================
# HTTP Listener
#
# CloudFront communicates with the ALB over HTTP.
# The browser communicates with CloudFront over HTTPS.
# =========================================================

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{\"error\":\"Route not found\"}"
      status_code  = "404"
    }
  }

  tags = {
    Name = "citibank-practice-backend-listener"
  }
}


# =========================================================
# Login Routing
#
# POST /auth/login
# GET  /auth/...
#
# -> Login ECS service
# =========================================================

resource "aws_lb_listener_rule" "login" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.login.arn
  }

  condition {
    path_pattern {
      values = ["/auth/*"]
    }
  }
}


# =========================================================
# Employee Routing
#
# /employees/*
#
# -> Employee ECS service
# =========================================================

resource "aws_lb_listener_rule" "employees" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.employees.arn
  }

  condition {
    path_pattern {
      values = ["/employees/*"]
    }
  }
}


# =========================================================
# Manager Routing
#
# /manager/*
#
# -> Manager ECS service
# =========================================================

resource "aws_lb_listener_rule" "managers" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.managers.arn
  }

  condition {
    path_pattern {
      values = ["/manager/*"]
    }
  }
}


# =========================================================
# Finance Administrator Routing
#
# /expenses/*
#
# -> Finance Administrator ECS service
# =========================================================

resource "aws_lb_listener_rule" "finance_admin" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.finance_admin.arn
  }

  condition {
    path_pattern {
      values = ["/expenses/*"]
    }
  }
}


# =========================================================
# Outputs
# =========================================================

output "backend_alb_dns_name" {
  description = "DNS name of the backend Application Load Balancer"
  value       = aws_lb.backend.dns_name
}

output "backend_alb_arn" {
  description = "ARN of the backend Application Load Balancer"
  value       = aws_lb.backend.arn
}