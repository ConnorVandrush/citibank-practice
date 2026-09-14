variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-2"
}

variable "github_connection_arn" {
  description = "ARN of the AWS CodeConnections connection to GitHub"
  type        = string
}