# API Gateway REST API
resource "aws_api_gateway_rest_api" "photo_gallery" {
  name        = var.api_name
  description = "Serverless Photo Gallery API with Fixed CORS"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(local.common_tags, {
    Name = var.api_name
    Type = "API Gateway"
  })
}

# API Gateway resource for /photos
resource "aws_api_gateway_resource" "photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  parent_id   = aws_api_gateway_rest_api.photo_gallery.root_resource_id
  path_part   = "photos"
}

# API Gateway resource for /photos/{photoId}
resource "aws_api_gateway_resource" "photo_id" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  parent_id   = aws_api_gateway_resource.photos.id
  path_part   = "{photoId}"
}

# GET /photos method
resource "aws_api_gateway_method" "get_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "GET"
  authorization = "NONE"
}

# HEAD /photos method (for connection test)
resource "aws_api_gateway_method" "head_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "HEAD"
  authorization = "NONE"
}

# POST /photos method
resource "aws_api_gateway_method" "post_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "POST"
  authorization = "NONE"
}

# DELETE /photos/{photoId} method
resource "aws_api_gateway_method" "delete_photo" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photo_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# OPTIONS method for /photos CORS
resource "aws_api_gateway_method" "options_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for /photos/{photoId} CORS
resource "aws_api_gateway_method" "options_photo_id" {
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  resource_id   = aws_api_gateway_resource.photo_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Lambda integrations
resource "aws_api_gateway_integration" "get_photos_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.get_photos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_photos.invoke_arn
}

resource "aws_api_gateway_integration" "head_photos_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.head_photos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_photos.invoke_arn
}

resource "aws_api_gateway_integration" "post_photos_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.post_photos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.upload_photo.invoke_arn
}

resource "aws_api_gateway_integration" "delete_photo_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photo_id.id
  http_method = aws_api_gateway_method.delete_photo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_photo.invoke_arn
}

# CORS OPTIONS integrations
resource "aws_api_gateway_integration" "options_photos_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.options_photos.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "options_photo_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photo_id.id
  http_method = aws_api_gateway_method.options_photo_id.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method responses for CORS OPTIONS
resource "aws_api_gateway_method_response" "options_photos_200" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.options_photos.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
    "method.response.header.Access-Control-Max-Age"           = false
    "method.response.header.Access-Control-Allow-Credentials" = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "options_photo_id_200" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photo_id.id
  http_method = aws_api_gateway_method.options_photo_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
    "method.response.header.Access-Control-Max-Age"           = false
    "method.response.header.Access-Control-Allow-Credentials" = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration responses for CORS OPTIONS
resource "aws_api_gateway_integration_response" "options_photos_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.options_photos.http_method
  status_code = aws_api_gateway_method_response.options_photos_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", var.cors_allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'GET,POST,OPTIONS,HEAD'"
    "method.response.header.Access-Control-Max-Age"           = "'86400'"
    "method.response.header.Access-Control-Allow-Credentials" = "'false'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method.options_photos]
}

resource "aws_api_gateway_integration_response" "options_photo_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id
  resource_id = aws_api_gateway_resource.photo_id.id
  http_method = aws_api_gateway_method.options_photo_id.http_method
  status_code = aws_api_gateway_method_response.options_photo_id_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", var.cors_allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'DELETE,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"           = "'86400'"
    "method.response.header.Access-Control-Allow-Credentials" = "'false'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method.options_photo_id]
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gw_lambda_list" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_photos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.photo_gallery.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_lambda_upload" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_photo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.photo_gallery.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_lambda_delete" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_photo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.photo_gallery.execution_arn}/*/*"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "photo_gallery" {
  depends_on = [
    aws_api_gateway_integration.get_photos_integration,
    aws_api_gateway_integration.head_photos_integration,
    aws_api_gateway_integration.post_photos_integration,
    aws_api_gateway_integration.delete_photo_integration,
    aws_api_gateway_integration.options_photos_integration,
    aws_api_gateway_integration.options_photo_id_integration,
    aws_api_gateway_integration_response.options_photos_integration_response,
    aws_api_gateway_integration_response.options_photo_id_integration_response,
  ]

  rest_api_id = aws_api_gateway_rest_api.photo_gallery.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.photos.id,
      aws_api_gateway_resource.photo_id.id,
      aws_api_gateway_method.get_photos.id,
      aws_api_gateway_method.head_photos.id,
      aws_api_gateway_method.post_photos.id,
      aws_api_gateway_method.delete_photo.id,
      aws_api_gateway_method.options_photos.id,
      aws_api_gateway_method.options_photo_id.id,
      aws_api_gateway_integration.get_photos_integration.id,
      aws_api_gateway_integration.head_photos_integration.id,
      aws_api_gateway_integration.post_photos_integration.id,
      aws_api_gateway_integration.delete_photo_integration.id,
      aws_api_gateway_integration.options_photos_integration.id,
      aws_api_gateway_integration.options_photo_id_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.photo_gallery.id
  rest_api_id   = aws_api_gateway_rest_api.photo_gallery.id
  stage_name    = var.environment

  tags = merge(local.common_tags, {
    Name = "${var.api_name}-${var.environment}"
    Type = "API Gateway Stage"
  })
}
