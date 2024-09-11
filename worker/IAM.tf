resource "aws_iam_role" "worker_lambda_role" {
  name = "worker_lambda_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "scheduler.amazonaws.com"
          ]
        }
      },
    ]
  })
}

# Resource (lambda) based.
# resource "aws_lambda_permission" "lambda_exec" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.call_webhook.function_name
#   principal     = "scheduler.amazonaws.com"
#   source_arn    = aws_scheduler_schedule.example.arn
# }

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = aws_iam_policy.lambda_exec.arn
}


resource "aws_iam_policy" "lambda_exec" {
  description = "Allow scheduler to invoke lambda"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
