# API Gateway
resource "aws_api_gateway_rest_api" "spa_api" {
  name        = "spa-upload-api"
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = {
    Name        = "${var.project_name}-upload-api"
    Environment = "prod"
    Project     = var.project_name
  }
}

# Resources
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

# Methods
resource "aws_api_gateway_method" "upload_post" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.upload_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "upload_options" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.upload_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "admin_post" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.admin_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "admin_options" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.admin_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "buckets_get" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.buckets_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "buckets_options" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.buckets_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "admin_buckets_post" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.admin_buckets_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "admin_buckets_options" {
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  resource_id   = aws_api_gateway_resource.admin_buckets_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "upload_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.direct_s3_upload_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "upload_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "admin_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.admin_file_manager_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "admin_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "buckets_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.list_s3_buckets_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "buckets_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "admin_buckets_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.bucket_administrator_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "admin_buckets_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method Responses
resource "aws_api_gateway_method_response" "upload_response_200" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "upload_options_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "admin_response_200" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "admin_options_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "buckets_response_200" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "buckets_options_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "admin_buckets_response_200" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "admin_buckets_options_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration Responses
resource "aws_api_gateway_integration_response" "upload_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_post.http_method
  status_code = aws_api_gateway_method_response.upload_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "upload_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_options.http_method
  status_code = aws_api_gateway_method_response.upload_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "admin_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_post.http_method
  status_code = aws_api_gateway_method_response.admin_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "admin_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_resource.id
  http_method = aws_api_gateway_method.admin_options.http_method
  status_code = aws_api_gateway_method_response.admin_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "buckets_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_get.http_method
  status_code = aws_api_gateway_method_response.buckets_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "buckets_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.buckets_resource.id
  http_method = aws_api_gateway_method.buckets_options.http_method
  status_code = aws_api_gateway_method_response.buckets_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "admin_buckets_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_post.http_method
  status_code = aws_api_gateway_method_response.admin_buckets_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://spa.chatwithjunle.com'"
  }
}

resource "aws_api_gateway_integration_response" "admin_buckets_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.spa_api.id
  resource_id = aws_api_gateway_resource.admin_buckets_resource.id
  http_method = aws_api_gateway_method.admin_buckets_options.http_method
  status_code = aws_api_gateway_method_response.admin_buckets_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://spa.chatwithjunle.com'"
  }
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_api_gateway_direct_s3_upload" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.direct_s3_upload_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.spa_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_admin_file_manager" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.admin_file_manager_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.spa_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_list_s3_buckets" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.list_s3_buckets_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.spa_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_bucket_administrator" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.bucket_administrator_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.spa_api.execution_arn}/*/*"
}

# Deployment and Stage
resource "aws_api_gateway_deployment" "spa_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.upload_lambda_integration,
    aws_api_gateway_integration.upload_options_integration,
    aws_api_gateway_integration.admin_lambda_integration,
    aws_api_gateway_integration.admin_options_integration,
    aws_api_gateway_integration.buckets_lambda_integration,
    aws_api_gateway_integration.buckets_options_integration,
    aws_api_gateway_integration.admin_buckets_lambda_integration,
    aws_api_gateway_integration.admin_buckets_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.spa_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "spa_api_stage" {
  deployment_id = aws_api_gateway_deployment.spa_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.spa_api.id
  stage_name    = var.stage_name

  tags = {
    Name        = "${var.project_name}-${var.stage_name}"
    Environment = "prod"
    Project     = var.project_name
  }
}
