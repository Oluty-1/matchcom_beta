variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod)"
  type        = string
}

variable "region" {
  description = "AWS region for general resources (e.g., DynamoDB, S3)"
  type        = string
}

variable "region_api_id" {
  description = "AWS region for API Gateway ARN"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for Lambda ZIP"
  type        = string
}

variable "s3_key" {
  description = "S3 key for Lambda ZIP"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "sqs_queue_url" {
  description = "SQS queue URL"
  type        = string
  default     = ""
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN"
  type        = string
  default     = ""
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = ""
}

variable "dynamodb_read_only" {
  description = "Whether Lambda has read-only DynamoDB access"
  type        = bool
  default     = false
}

variable "api_gateway_id" {
  description = "API Gateway REST API ID"
  type        = string
  default     = ""
}

variable "api_gateway_resource_id" {
  description = "API Gateway resource ID"
  type        = string
  default     = ""
}

variable "api_gateway_http_method" {
  description = "API Gateway HTTP method"
  type        = string
  default     = ""
}

variable "api_resource_path" {
  description = "API Gateway resource path"
  type        = string
  default     = ""
}

variable "enable_sqs" {
  description = "Enable SQS event source mapping"
  type        = bool
  default     = false
}

variable "enable_api_gateway" {
  description = "Enable API Gateway integration"
  type        = bool
  default     = false
}

variable "notification_emails" {
  description = "List of emails for SNS notifications"
  type        = list(string)
  default     = []
}