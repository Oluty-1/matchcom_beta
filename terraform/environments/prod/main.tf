module "shared" {
  source      = "../../modules/shared"
  environment = var.environment
  region      = var.region
  alarm_email = var.alarm_email
  integration_ids = [
    module.calculate_compatibility.integration_id,
    module.get_compatibility.integration_id,
    module.update_compatibility.integration_id,
    module.delete_compatibility.integration_id
  ]
}

module "calculate_compatibility" {
  source                  = "../../modules/lambda"
  function_name           = "CalculateCompatibilityFunction"
  environment             = var.environment
  region                  = var.region
  region_api_id           = var.region
  account_id              = "302225372317"
  s3_bucket               = "compatibility-bucket-test"
  s3_key                  = "functions/calculateCompatibility/function.zip"
  runtime                 = "nodejs22.x"
  timeout                 = 16
  sqs_queue_url           = module.shared.queue_url
  sqs_queue_arn           = module.shared.queue_arn
  api_gateway_id          = module.shared.api_gateway_id
  api_gateway_resource_id = module.shared.compatibility_resource_id
  api_gateway_http_method = "POST"
  api_resource_path       = "/compatibility"
  enable_sqs              = false
  enable_api_gateway      = true
  analytics_emails        = ["tayoefunshile@gmail.com"]
  dlq_arn                 = module.shared.queue_dlq_arn
}

module "process_compatibility" {
  source                  = "../../modules/lambda"
  function_name           = "ProcessCompatibilityFunction"
  environment             = var.environment
  region                  = var.region
  region_api_id           = var.region
  account_id              = "302225372317"
  s3_bucket               = "compatibility-bucket-test"
  s3_key                  = "functions/processCompatibility/function.zip"
  runtime                 = "nodejs22.x"
  timeout                 = 10
  sqs_queue_url           = module.shared.queue_url
  sqs_queue_arn           = module.shared.queue_arn
  dynamodb_table_name     = module.shared.table_name
  api_gateway_id          = ""
  api_gateway_resource_id = ""
  api_gateway_http_method = ""
  api_resource_path       = ""
  enable_sqs              = true
  enable_api_gateway      = false
  analytics_emails        = ["tayoefunshile@gmail.com"]
  dlq_arn                 = module.shared.queue_dlq_arn
}

module "get_compatibility" {
  source                  = "../../modules/lambda"
  function_name           = "GetCompatibilityFunction"
  environment             = var.environment
  region                  = var.region
  region_api_id           = var.region
  account_id              = "302225372317"
  s3_bucket               = "compatibility-bucket-test"
  s3_key                  = "functions/getCompatibility/function.zip"
  runtime                 = "nodejs22.x"
  timeout                 = 10
  dynamodb_table_name     = module.shared.table_name
  dynamodb_read_only      = true
  api_gateway_id          = module.shared.api_gateway_id
  api_gateway_resource_id = module.shared.compatibility_id_resource_id
  api_gateway_http_method = "GET"
  api_resource_path       = "/compatibility/{id}"
  enable_sqs              = false
  enable_api_gateway      = true
  analytics_emails        = ["tayoefunshile@gmail.com"]
  dlq_arn                 = module.shared.queue_dlq_arn
}

module "update_compatibility" {
  source                  = "../../modules/lambda"
  function_name           = "UpdateCompatibilityFunction"
  environment             = var.environment
  region                  = var.region
  region_api_id           = var.region
  account_id              = "302225372317"
  s3_bucket               = "compatibility-bucket-test"
  s3_key                  = "functions/updateCompatibility/function.zip"
  runtime                 = "nodejs22.x"
  timeout                 = 10
  dynamodb_table_name     = module.shared.table_name
  api_gateway_id          = module.shared.api_gateway_id
  api_gateway_resource_id = module.shared.compatibility_id_resource_id
  api_gateway_http_method = "PUT"
  api_resource_path       = "/compatibility/{id}"
  enable_sqs              = false
  enable_api_gateway      = true
  analytics_emails        = ["tayoefunshile@gmail.com"]
  dlq_arn                 = module.shared.queue_dlq_arn
}

module "delete_compatibility" {
  source                  = "../../modules/lambda"
  function_name           = "DeleteCompatibilityFunction"
  environment             = var.environment
  region                  = var.region
  region_api_id           = var.region
  account_id              = "302225372317"
  s3_bucket               = "compatibility-bucket-test"
  s3_key                  = "functions/deleteCompatibility/function.zip"
  runtime                 = "nodejs22.x"
  timeout                 = 10
  dynamodb_table_name     = module.shared.table_name
  api_gateway_id          = module.shared.api_gateway_id
  api_gateway_resource_id = module.shared.compatibility_id_resource_id
  api_gateway_http_method = "DELETE"
  api_resource_path       = "/compatibility/{id}"
  enable_sqs              = false
  enable_api_gateway      = true
  analytics_emails        = ["tayoefunshile@gmail.com"]
  dlq_arn                 = module.shared.queue_dlq_arn
}