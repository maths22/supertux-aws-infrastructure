data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir = "${path.module}/function"
  output_path = "${path.module}/function.zip"
}

locals {
  function_name = "supertux-download-api"
}

resource "aws_lambda_function" "function" {
  filename      = data.archive_file.lambda_source.output_path
  function_name = local.function_name
  role          = aws_iam_role.function_role.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.lambda_source.output_base64sha256

  runtime       = "nodejs22.x"
  timeout       = 10
  memory_size   = 512
  architectures = ["arm64"]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.downloads.name
    }
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
