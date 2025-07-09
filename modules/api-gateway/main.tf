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
