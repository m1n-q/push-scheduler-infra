output "worker_lambda_arn" {
  value = aws_lambda_function.call_webhook.arn
}

output "worker_lambda_role_arn" {
  value = aws_iam_role.worker_lambda_role.arn
}