# ==========================================
# IAM Role da Lambda
# ==========================================

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ==========================================
# Permissões básicas de logs
# ==========================================

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ==========================================
# Arquivo ZIP da Lambda
# ==========================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ==========================================
# Função Lambda
# ==========================================

resource "aws_lambda_function" "pedidos" {
  function_name = "${var.project_name}-pedidos"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = aws_iam_role.lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  tags = {
    Name    = "${var.project_name}-lambda"
    Projeto = var.project_name
  }
}
# ==========================================
# Permissão para a Lambda ler mensagens do SQS
# ==========================================

resource "aws_iam_role_policy" "lambda_sqs" {
  name = "${var.project_name}-lambda-sqs-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = aws_sqs_queue.pedidos.arn
      }
    ]
  })
}

# ==========================================
# Trigger SQS para a Lambda
# ==========================================

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.pedidos.arn
  function_name    = aws_lambda_function.pedidos.arn
  batch_size       = 10
  enabled          = true
}
# ==========================================
# Grupo de logs da Lambda
# ==========================================

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.pedidos.function_name}"
  retention_in_days = 7

  tags = {
    Name    = "${var.project_name}-lambda-logs"
    Projeto = var.project_name
  }
}