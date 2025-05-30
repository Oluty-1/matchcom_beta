variable "environment" {
  description = "Environment name (e.g., prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "alarm_email" {
  description = "Email for SNS alarm notifications"
  type        = string
}

variable "integration_ids" {
  description = "List of API Gateway integration IDs"
  type        = list(string)
  default     = []
}