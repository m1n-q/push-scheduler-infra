/*
 * GET /schedules
 */
resource "aws_lambda_function" "get_schedules" {
  filename      = "${path.module}/get_schedules.zip"
  function_name = "GetSchedules"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "get_schedules.handler"

  runtime = var.python_version
  layers = [aws_lambda_layer_version.shared_module.arn, aws_lambda_layer_version.auth_module.arn]
  source_code_hash = data.archive_file.get_schedules.output_base64sha256
  environment {
    variables = {
      JWT_PUBLIC_KEY = tls_private_key.jwt_key_pair.public_key_pem
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.get_schedules
  ]
}

resource "aws_cloudwatch_log_group" "get_schedules" {
  name              = "/aws/lambda/GetSchedules"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "get_schedules" {
  type        = "zip"
  source_file  = "${path.module}/get_schedules.py"
  output_path = "${path.module}/get_schedules.zip"
}


/*
 * POST /schedules
 */
resource "aws_lambda_function" "create_schedule" {
  filename      = "${path.module}/create_schedule.zip"
  function_name = "CreateSchedule"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "create_schedule.handler"

  runtime = var.python_version
  layers = [aws_lambda_layer_version.shared_module.arn, aws_lambda_layer_version.auth_module.arn]
  environment {
    variables = {
      WORKER_LAMBDA_ARN = var.worker_lambda_arn
      WORKER_LAMBDA_ROLE_ARN = var.worker_lambda_role_arn
      JWT_PUBLIC_KEY = tls_private_key.jwt_key_pair.public_key_pem
    }
  }
  source_code_hash = data.archive_file.create_schedule.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.create_schedule
  ]
}

resource "aws_cloudwatch_log_group" "create_schedule" {
  name              = "/aws/lambda/CreateSchedule"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "create_schedule" {
  type        = "zip"
  source_file  = "${path.module}/create_schedule.py"
  output_path = "${path.module}/create_schedule.zip"
}

/*
 * PUT /schedules/{name:base64}
 */
resource "aws_lambda_function" "update_schedule" {
  filename      = "${path.module}/update_schedule.zip"
  function_name = "UpdateSchedule"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "update_schedule.handler"

  runtime = var.python_version
  layers = [aws_lambda_layer_version.shared_module.arn, aws_lambda_layer_version.auth_module.arn]
  source_code_hash = data.archive_file.update_schedule.output_base64sha256
  environment {
    variables = {
      JWT_PUBLIC_KEY = tls_private_key.jwt_key_pair.public_key_pem
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.update_schedule
  ]
}

resource "aws_cloudwatch_log_group" "update_schedule" {
  name              = "/aws/lambda/UpdateSchedule"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "update_schedule" {
  type        = "zip"
  source_file  = "${path.module}/update_schedule.py"
  output_path = "${path.module}/update_schedule.zip"
}


/*
 * DELETE /schedules/{name:base64}
 */
resource "aws_lambda_function" "delete_schedule" {
  filename      = "${path.module}/delete_schedule.zip"
  function_name = "DeleteSchedule"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "delete_schedule.handler"

  runtime = var.python_version
  layers = [aws_lambda_layer_version.shared_module.arn, aws_lambda_layer_version.auth_module.arn]
  source_code_hash = data.archive_file.delete_schedule.output_base64sha256
  environment {
    variables = {
      JWT_PUBLIC_KEY = tls_private_key.jwt_key_pair.public_key_pem
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.delete_schedule
  ]
}

resource "aws_cloudwatch_log_group" "delete_schedule" {
  name              = "/aws/lambda/DeleteSchedule"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "delete_schedule" {
  type        = "zip"
  source_file  = "${path.module}/delete_schedule.py"
  output_path = "${path.module}/delete_schedule.zip"
}


/*
 * POST /login
 */
resource "aws_lambda_function" "seatalk_sso" {
  filename      = "${path.module}/seatalk_sso.zip"
  function_name = "SeatalkSSO"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "seatalk_sso.handler"

  runtime = var.python_version
  layers = [aws_lambda_layer_version.auth_module.arn]
  source_code_hash = data.archive_file.seatalk_sso.output_base64sha256
  environment {
    variables = {
      JWT_PRIVATE_KEY = tls_private_key.jwt_key_pair.private_key_pem
      SEATALK_APP_ID = var.seatalk_app_id
      SEATALK_APP_SECRET = var.seatalk_app_secret
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.seatalk_sso
  ]
}

resource "aws_cloudwatch_log_group" "seatalk_sso" {
  name              = "/aws/lambda/SeatalkSSO"

  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "seatalk_sso" {
  type        = "zip"
  source_file  = "${path.module}/seatalk_sso.py"
  output_path = "${path.module}/seatalk_sso.zip"
}
