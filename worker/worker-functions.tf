data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/index.mjs"
  output_path = "${path.module}/call_webhook.zip"
}

resource "aws_lambda_function" "call_webhook" {
  filename      = "${path.module}/call_webhook.zip"
  function_name = "CallWebhook"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"

  runtime = var.nodejs_version

  depends_on = [
    aws_cloudwatch_log_group.call_webhook,
  ]
}

resource "aws_cloudwatch_log_group" "call_webhook" {
  name              = "/aws/lambda/CallWebhook"

  lifecycle {
    prevent_destroy = false
  }
}