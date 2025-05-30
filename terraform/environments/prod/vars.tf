variable "environment" {
  type        = string
  description = "Environment (e.g., prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "alarm_email" {
  type        = string
  description = "Email for SNS alarm notifications"
}