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

resource "aws_api_gateway_method" "calculate_compatibility_post" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  resource_id   = aws_api_gateway_resource.compatibility_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_compatibility_get" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  resource_id   = aws_api_gateway_resource.compatibility_id_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "update_compatibility_put" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  resource_id   = aws_api_gateway_resource.compatibility_id_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_compatibility_delete" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  resource_id   = aws_api_gateway_resource.compatibility_id_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "compatibility_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.compatibility_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.calculate_compatibility_post,
      aws_api_gateway_method.get_compatibility_get,
      aws_api_gateway_method.update_compatibility_put,
      aws_api_gateway_method.delete_compatibility_delete,
      var.integration_ids
    ]))
  }
}

resource "aws_api_gateway_stage" "compatibility_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.compatibility_api.id
  deployment_id = aws_api_gateway_deployment.compatibility_api_deployment.id
  stage_name    = var.environment
}