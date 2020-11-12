
resource "aws_iam_policy" "version_checkerlambda_logging_policy" {
  name = "${var.app_prefix}-lambda-logging-policy"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.version_checker_lambda_role.name}"
  policy_arn = "${aws_iam_policy.version_checkerlambda_logging_policy.arn}"
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_version_checker.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.version_checker_api.execution_arn}/*/*/*"
  depends_on = ["aws_lambda_function.lambda_version_checker","aws_api_gateway_rest_api.version_checker_api"]
}

resource "aws_lambda_permission" "apigw_lambda_active_alias" {
  statement_id  = "AllowExecutionFromAPIGatewayToAlias"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_alias.lambda_function_alias_active.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.version_checker_api.execution_arn}/*/*/*"
  depends_on = ["aws_lambda_function.lambda_version_checker","aws_api_gateway_rest_api.version_checker_api"]
}

resource "aws_lambda_permission" "apigw_lambda_black_alias" {
  statement_id  = "AllowExecutionFromAPIGatewayToBlackAlias"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_alias.lambda_function_alias_black.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.version_checker_api.execution_arn}/*/*/*"
  depends_on = ["aws_lambda_function.lambda_version_checker","aws_api_gateway_rest_api.version_checker_api"]
}

resource "aws_lambda_permission" "apigw_lambda_red_alias" {
  statement_id  = "AllowExecutionFromAPIGatewayToRedAlias"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_alias.lambda_function_alias_red.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.version_checker_api.execution_arn}/*/*/*"
  depends_on = ["aws_lambda_function.lambda_version_checker","aws_api_gateway_rest_api.version_checker_api"]
}


resource "aws_iam_role_policy" "version_checker_api_gateway_cloudwatch_policy" {
  name = "${var.app_prefix}-api-gateway-cloudwatch-policy"
  role = "${aws_iam_role.version_checker_api_gateway_cloudwatch_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}