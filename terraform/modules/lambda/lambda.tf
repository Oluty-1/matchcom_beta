data "aws_s3_object" "lambda_zip" {
  bucket = var.s3_bucket
  key    = var.s3_key
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = var.runtime
  timeout          = var.timeout
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = data.aws_s3_object.lambda_zip.metadata["source_code_hash"]
  environment {
    variables = merge(
      {
        ENVIRONMENT = var.function_name
      },
      var.sqs_queue_url != "" ? { SQS_QUEUE_URL = var.sqs_queue_url } : {},
      var.dynamodb_table_name != "" ? { TABLE_NAME = var.dynamodb_table_name } : {}
    )
  }
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  count            = var.enable_sqs ? 1 : 0
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.lambda.arn
  batch_size       = 10
}

resource "aws_api_gateway_integration" "lambda_integration" {
  count                   = var.enable_api_gateway ? 1 : 0
  rest_api_id             = var.api_gateway_id
  resource_id             = var.api_gateway_resource_id
  http_method             = var.api_gateway_http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  count         = var.enable_api_gateway ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region_api_id}:${var.account_id}:${var.api_gateway_id}/*/${var.api_gateway_http_method}${var.api_resource_path}"
}

output "integration_id" {
  value = var.enable_api_gateway ? aws_api_gateway_integration.lambda_integration[0].id : ""
}