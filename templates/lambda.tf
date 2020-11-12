resource "aws_lambda_function" "lambda_version_checker" {
  filename      = "${var.lambda_source_zip_path}"
  function_name = "${var.app_prefix}-lambda"
  role          = "${aws_iam_role.version_checker_lambda_role.arn}"
  handler       = "codeandtech.VersionHandler::handleRequest"
  runtime       = "java8"
  memory_size   = 2048
  timeout       = 300
  
  source_code_hash = "${filebase64sha256(var.lambda_source_zip_path)}"
  depends_on = ["aws_iam_role.version_checker_lambda_role"]

  environment {
    variables = {
      PROJECT = "Ingest"
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_version_kinesis_mapping" {
  event_source_arn  = "${aws_kinesis_stream.lambda_version_checker_stream.arn}"
  #function_name     = "${aws_lambda_function.lambda_version_checker.arn}"
  function_name     = "${aws_lambda_alias.lambda_function_alias_active.arn}"
  starting_position = "LATEST"
}

resource "aws_lambda_alias" "lambda_function_alias_active" {
  name             = "active"
  function_name    = "${var.app_prefix}-lambda"
  function_version = "$LATEST"

  depends_on = ["aws_lambda_function.lambda_version_checker"]
}

resource "aws_lambda_alias" "lambda_function_alias_black" {
  name             = "black"
  function_name    = "${var.app_prefix}-lambda"
  function_version = "$LATEST"

  depends_on = ["aws_lambda_function.lambda_version_checker"]
}

resource "aws_lambda_alias" "lambda_function_alias_red" {
  name             = "red"
  function_name    = "${var.app_prefix}-lambda"
  function_version = "$LATEST"

  depends_on = ["aws_lambda_function.lambda_version_checker"]
}

output "lambda_version_checker" {
  value = "${aws_lambda_function.lambda_version_checker}"
}
