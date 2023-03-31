#
# lambda role
#
# lambda assume role policy
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# lambda dynamodb role policy
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          aws_dynamodb_table.visitor2-dynamodb.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# cloudwatch log policy
resource "aws_iam_policy" "lambda_cloudwatch_logging_policy" {
  name = "lambda-cloudwatch-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logging_policy.arn
}

#
# api gateway role
#
data "aws_iam_policy_document" "api_gateway_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "${var.project_name}-api-gateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role_policy.json
}

# api gateway cloudwatch logging policy
data "aws_iam_policy_document" "api_gateway_cloudwatch_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name   = "api-gateway-cloudwatch-policy"
  role   = aws_iam_role.api_gateway_role.id
  policy = data.aws_iam_policy_document.api_gateway_cloudwatch_logging_policy.json
}

# resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_attachment" {
#   role       = aws_iam_role.api_gateway_role.name
#   policy_arn = aws_iam_policy.api_gateway_cloudwatch_logging_policy.arn
# }

# create api gateway account
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn
}

# dynamodb assume role policy
# data "aws_iam_policy_document" "dynamodb_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["dynamodb.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "dynamodb_role" {
#   name               = "${var.project_name}-dynamodb-role"
#   assume_role_policy = data.aws_iam_policy_document.dynamodb_assume_role_policy.json
# }
