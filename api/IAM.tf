/* Lambda: Log • Eventbridge access */
resource "aws_iam_role" "api_lambda_role" {
  name = "api_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pass_role" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.pass_role.arn
}

// TODO: separate role for each api
resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy_attachment" "lambda_manage_scheduler" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.allow_manage_scheduler.arn
}


resource "aws_iam_policy" "allow_manage_scheduler" {
  description = "Allow list Eventbridge Scheduler"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "scheduler:ListSchedules",
          "scheduler:GetSchedules",
          "scheduler:GetSchedule",
          "scheduler:CreateSchedule",
          "scheduler:UpdateSchedule",
          "scheduler:DeleteSchedule",
          "scheduler:CreateScheduleGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "pass_role" {
  description = "Allow lambda to pass role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
