resource "aws_apigatewayv2_api" "api" {
  name          = "api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [var.cors_origin_dev, var.cors_origin_prod]
    allow_headers = ["*"]
    allow_methods = ["OPTIONS","GET","POST","PUT","DELETE"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Routes
resource "aws_apigatewayv2_route" "preflight" {
  route_key = "OPTIONS /{proxy+}"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.get_schedules.id}"
}

resource "aws_apigatewayv2_route" "get_schedules" {
  route_key = "GET /schedules"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.get_schedules.id}"

  authorizer_id = aws_apigatewayv2_authorizer.example.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "create_schedule" {
  route_key = "POST /schedules"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.create_schedule.id}"

  authorizer_id = aws_apigatewayv2_authorizer.example.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "update_schedule" {
  route_key = "PUT /schedules/{scheduleNameBase64}"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.update_schedule.id}"

  authorizer_id = aws_apigatewayv2_authorizer.example.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "delete_schedule" {
  route_key = "DELETE /schedules/{scheduleNameBase64}"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.delete_schedule.id}"

  authorizer_id = aws_apigatewayv2_authorizer.example.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "seatalk_sso" {
  route_key = "POST /login"

  api_id = aws_apigatewayv2_api.api.id
  target = "integrations/${aws_apigatewayv2_integration.seatalk_sso.id}"
}


resource "aws_apigatewayv2_integration" "get_schedules" {
  api_id = aws_apigatewayv2_api.api.id
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-integration-types.html
  integration_type = "AWS_PROXY"
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias.html#invoke_arn
  integration_uri        = aws_lambda_function.get_schedules.invoke_arn
  payload_format_version = "2.0"
}


resource "aws_apigatewayv2_integration" "create_schedule" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create_schedule.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "update_schedule" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.update_schedule.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "delete_schedule" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete_schedule.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "seatalk_sso" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.seatalk_sso.invoke_arn
  payload_format_version = "2.0"
}


# Permission
locals {
  all_functions = [
    aws_lambda_function.get_schedules.function_name,
    aws_lambda_function.create_schedule.function_name,
    aws_lambda_function.update_schedule.function_name,
    aws_lambda_function.delete_schedule.function_name,
    aws_lambda_function.seatalk_sso.function_name,
    aws_lambda_function.api_authorizer.function_name
  ]
}
resource "aws_lambda_permission" "invoke_lambda" {
  for_each = toset(local.all_functions)

  function_name = each.value
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
}


resource "aws_apigatewayv2_authorizer" "example" {
  api_id                            = aws_apigatewayv2_api.api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.api_authorizer.invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "ApiAuthorizer"
  authorizer_payload_format_version = "1.0"

  authorizer_result_ttl_in_seconds = 0 # disable cache
}

resource "aws_lambda_function" "api_authorizer" {
  filename      = "${path.module}/api_authorizer.zip"
  function_name = "ApiAuthorizer"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "api_authorizer.handler"

  runtime          = var.python_version
  source_code_hash = data.archive_file.api_authorizer.output_base64sha256
  layers = [
    aws_lambda_layer_version.auth_module.arn
  ]

  environment {
    variables = {
      JWT_PUBLIC_KEY = tls_private_key.jwt_key_pair.public_key_pem
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.api_authorizer
  ]
}

resource "aws_cloudwatch_log_group" "api_authorizer" {
  name = "/aws/lambda/ApiAuthorizer"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "api_authorizer" {
  type        = "zip"
  source_file  = "${path.module}/api_authorizer.py"
  output_path = "${path.module}/api_authorizer.zip"
}

resource "tls_private_key" "jwt_key_pair" {
  algorithm = "RSA"
}