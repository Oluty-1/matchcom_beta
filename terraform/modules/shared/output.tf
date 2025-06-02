output "queue_url" {
  value = aws_sqs_queue.compatibility_queue.id
}

output "queue_arn" {
  value = aws_sqs_queue.compatibility_queue.arn
}

output "table_name" {
  value = aws_dynamodb_table.results_table.name
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.compatibility_api.id
}

output "compatibility_resource_id" {
  value = aws_api_gateway_resource.compatibility_resource.id
}

output "compatibility_id_resource_id" {
  value = aws_api_gateway_resource.compatibility_id_resource.id
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.compatibility_api.id}.execute-api.${var.region}.amazonaws.com/${var.environment}"
}

output "queue_dlq_arn" {
  value = aws_sqs_queue.compatibility_dlq.arn
}