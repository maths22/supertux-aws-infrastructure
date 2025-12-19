data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.function_name}:*"]
  }
}

resource "aws_iam_role_policy" "lambda_logging_policy" {
  name   = "supertux-download-api-logging"
  role   = aws_iam_role.function_role.id
  policy = data.aws_iam_policy_document.lambda_logging.json
}

data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = ["${aws_dynamodb_table.downloads.arn}/*"]
  }
}

resource "aws_iam_role_policy" "dynamodb_access_policy" {
  name   = "supertux-download-api-dynamodb-access"
  role   = aws_iam_role.function_role.id
  policy = data.aws_iam_policy_document.dynamodb_access.json
}

resource "aws_iam_role" "function_role" {
  name               = "supertux-download-api"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
