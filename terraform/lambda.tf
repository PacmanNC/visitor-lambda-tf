data "archive_file" "zip" {
  type        = "zip"
  source_file = "../lambda/main.py"
  output_path = "../lambda/main.zip"
}

resource "aws_lambda_function" "visitor2" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)

  function_name = var.project_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  timeout       = 10
  # publish       = true

  environment {
    variables = {
      DB_NAME = var.db_name
    }
  }
}

resource "aws_lambda_alias" "alias_stage" {
  name             = var.stage
  description      = var.stage
  function_name    = aws_lambda_function.visitor2.arn
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor2.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_lambda_permission" "permission_stage" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.visitor2.function_name}:${var.stage}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${var.api_resource_name}"
}

resource "aws_cloudwatch_log_group" "convert_log_group" {
  name = "/aws/lambda/${aws_lambda_function.visitor2.function_name}"
  retention_in_days = 1
  # lifecycle {
  #   prevent_destroy = true
  # }
}