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

  # TOOD arm64

  runtime = "nodejs18.x"
  timeout = 10

# TODO pass things
  # environment {
  #   variables = {
  #     ENVIRONMENT = "production"
  #     LOG_LEVEL   = "info"
  #   }
  # }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
