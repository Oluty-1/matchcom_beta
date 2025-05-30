resource "aws_api_gateway_rest_api" "compatibility_api" {
  name        = "CompatibilityApi-${var.environment}"
  description = "Compatibility Calculator API"
}

resource "aws_api_gateway_resource" "compatibility_resource" {
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  parent_id   = aws_api_gateway_rest_api.compatibility_api.root_resource_id
  path_part   = "compatibility"
}

resource "aws_api_gateway_resource" "compatibility_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  parent_id   = aws_api_gateway_resource.compatibility_resource.id
  path_part   = "{id}"
}

locals {
  methods = {
    "POST_compatibility" = {
      http_method = "POST"
      resource_id = aws_api_gateway_resource.compatibility_resource.id
      is_options  = false
    }
    "GET_compatibility_id" = {
      http_method = "GET"
      resource_id = aws_api_gateway_resource.compatibility_id_resource.id
      is_options  = false
    }
    "PUT_compatibility_id" = {
      http_method = "PUT"
      resource_id = aws_api_gateway_resource.compatibility_id_resource.id
      is_options  = false
    }
    "DELETE_compatibility_id" = {
      http_method = "DELETE"
      resource_id = aws_api_gateway_resource.compatibility_id_resource.id
      is_options  = false
    }
    "OPTIONS_compatibility" = {
      http_method = "OPTIONS"
      resource_id = aws_api_gateway_resource.compatibility_resource.id
      is_options  = true
    }
    "OPTIONS_compatibility_id" = {
      http_method = "OPTIONS"
      resource_id = aws_api_gateway_resource.compatibility_id_resource.id
      is_options  = true
    }
  }
}

resource "aws_api_gateway_method" "method" {
  for_each      = local.methods
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  resource_id   = each.value.resource_id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  for_each = { for k, v in local.methods : k => v if v.is_options }
  rest_api_id             = aws_api_gateway_rest_api.compatibility_api.id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_method.method]
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each    = local.methods
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = each.value.is_options
    "method.response.header.Access-Control-Allow-Headers" = each.value.is_options
  }
  response_models = each.value.is_options ? { "application/json" = "Empty" } : {}
  depends_on = [aws_api_gateway_method.method] 
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = { for k, v in local.methods : k => v if v.is_options }
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date'"
  }
  depends_on = [
    aws_api_gateway_method_response.response_200,
    aws_api_gateway_integration.options_integration
  ]
}

resource "aws_api_gateway_deployment" "compatibility_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      local.methods,
      var.integration_ids
    ]))
  }
  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.options_integration
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "compatibility_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  deployment_id = aws_api_gateway_deployment.compatibility_api_deployment.id
  stage_name    = var.environment
  depends_on    = [aws_api_gateway_deployment.compatibility_api_deployment]
  lifecycle {
    create_before_destroy = true
  }
}