# =========================================================
# CloudFront Origin Access Control
#
# Allows CloudFront to securely access the private S3 bucket
# using SigV4.
# =========================================================

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "citibank-practice-frontend-oac"
  description                       = "CloudFront access to the private frontend S3 bucket"
  origin_access_control_origin_type = "s3"

  signing_behavior = "always"
  signing_protocol = "sigv4"
}


# =========================================================
# CloudFront Distribution
# =========================================================

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  # =======================================================
  # Origin 1: Private S3 Frontend
  # =======================================================

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name

    origin_id = "S3-${aws_s3_bucket.frontend.id}"

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }


  # =======================================================
  # Origin 2: Backend Application Load Balancer
  #
  # CloudFront communicates with the ALB over HTTP.
  # The browser communicates with CloudFront over HTTPS.
  # =======================================================

  origin {
    domain_name = aws_lb.backend.dns_name

    origin_id = "ALB-${aws_lb.backend.id}"

    custom_origin_config {
      http_port  = 80
      https_port = 443

      origin_protocol_policy = "http-only"

      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }


  # =======================================================
  # Default Cache Behavior
  #
  # All paths that don't match a backend API behavior go
  # to the frontend S3 bucket.
  #
  # Examples:
  #
  # /
  # /index.html
  # /assets/index.js
  # /dashboard
  # =======================================================

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    target_origin_id = "S3-${aws_s3_bucket.frontend.id}"

    viewer_protocol_policy = "redirect-to-https"

    compress = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }


  # =======================================================
  # Login API
  #
  # /auth/*
  #
  # Example:
  #
  # POST /auth/login
  #
  # → ALB
  # → Login Target Group
  # → Login ECS
  # =======================================================

  ordered_cache_behavior {
    path_pattern = "/auth/*"

    target_origin_id = "ALB-${aws_lb.backend.id}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = true

      headers = [
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "all"
      }
    }
  }


  # =======================================================
  # Employee API
  #
  # /employees/*
  #
  # → ALB
  # → Employee Target Group
  # → Employee ECS
  # =======================================================

  ordered_cache_behavior {
    path_pattern = "/employees/*"

    target_origin_id = "ALB-${aws_lb.backend.id}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = true

      headers = [
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "all"
      }
    }
  }


  # =======================================================
  # Manager API
  #
  # /manager/*
  #
  # → ALB
  # → Manager Target Group
  # → Manager ECS
  # =======================================================

  ordered_cache_behavior {
    path_pattern = "/manager/*"

    target_origin_id = "ALB-${aws_lb.backend.id}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = true

      headers = [
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "all"
      }
    }
  }


  # =======================================================
  # Finance Administrator API
  #
  # /expenses/*
  #
  # → ALB
  # → Finance Admin Target Group
  # → Finance Admin ECS
  # =======================================================

  ordered_cache_behavior {
    path_pattern = "/expenses/*"

    target_origin_id = "ALB-${aws_lb.backend.id}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = true

      headers = [
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "all"
      }
    }
  }


  # =======================================================
  # React / Vite SPA Routing
  #
  # S3 returns index.html for routes that don't correspond
  # to a physical file.
  # =======================================================

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }


  # =======================================================
  # Geographic Restrictions
  # =======================================================

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  # =======================================================
  # CloudFront Default Certificate
  #
  # No custom domain is required.
  # CloudFront provides:
  #
  # https://<distribution>.cloudfront.net
  # =======================================================

  viewer_certificate {
    cloudfront_default_certificate = true

    minimum_protocol_version = "TLSv1.2_2021"
  }


  # =======================================================
  # Price Class
  # =======================================================

  price_class = "PriceClass_100"


  # =======================================================
  # Tags
  # =======================================================

  tags = {
    Name = "citibank-practice-frontend-cloudfront"
  }
}


# =========================================================
# S3 Bucket Policy
#
# Keeps the S3 bucket private.
#
# Only this CloudFront distribution can read objects.
# =========================================================

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [
    aws_cloudfront_distribution.frontend
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.frontend.arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}


# =========================================================
# Outputs
# =========================================================

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the frontend"

  value = aws_cloudfront_distribution.frontend.id
}


output "cloudfront_domain_name" {
  description = "CloudFront domain name for the frontend"

  value = aws_cloudfront_distribution.frontend.domain_name
}