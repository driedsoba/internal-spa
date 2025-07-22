# API Gateway
resource "aws_api_gateway_rest_api" "spa_api" {
  name        = "spa-upload-api"
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = {
    Name      = "${var.project_name}-upload-api"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# API Gateway Resources
resource "aws_api_gateway_resource" "upload_resource" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  parent_id   = aws_api_gateway_rest_api.spa_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_resource" "admin_resource" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  parent_id   = aws_api_gateway_rest_api.spa_api.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "buckets_resource" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  parent_id   = aws_api_gateway_rest_api.spa_api.root_resource_id
  path_part   = "buckets"
}

resource "aws_api_gateway_resource" "admin_buckets_resource" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "buckets"
}

# API Gateway Methods
resource "aws_api_gateway_method" "upload_post" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.upload_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integrations
resource "aws_api_gateway_integration" "upload_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.spa_api.id
  resource_id             = aws_api_gateway_resource.upload_resource.id
  http_method             = aws_api_gateway_method.upload_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.direct_s3_upload_lambda_invoke_arn
}

# Method Response
resource "aws_api_gateway_method_response" "upload_response_200" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration Response
resource "aws_api_gateway_integration_response" "upload_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_post.http_method
  status_code = aws_api_gateway_method_response.upload_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://spa.chatwithjunle.com'"
  }

  depends_on = [aws_api_gateway_integration.upload_lambda_integration]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "spa_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.upload_resource.id,
      aws_api_gateway_method.upload_post.id,
      aws_api_gateway_integration.upload_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.upload_post,
    aws_api_gateway_integration.upload_lambda_integration,
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "spa_api_stage" {
  deployment_id = aws_api_gateway_deployment.spa_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  stage_name    = var.stage_name
}
