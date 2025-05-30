resource "aws_sqs_queue" "compatibility_queue" {
  name                       = "CompatibilityQueue-${var.environment}"
  sqs_managed_sse_enabled    = true
  visibility_timeout_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.compatibility_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "compatibility_dlq" {
  name                    = "CompatibilityDLQ-${var.environment}"
  sqs_managed_sse_enabled = true
}