
resource "aws_api_gateway_rest_api" "version_checker_api" {
  name = "${var.app_prefix}-api"
  description = "lambda version validator api"
  
}

#create a resource with name 'resource' in the gateway api , many resources can be created like this
resource "aws_api_gateway_resource" "resource" {
  path_part   = "lambdaversioncheck"
  parent_id   = "${aws_api_gateway_rest_api.version_checker_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  depends_on = ["aws_api_gateway_rest_api.version_checker_api"]
}

resource "aws_api_gateway_account" "version_checker_api_gateway_account" {
  cloudwatch_role_arn = "${aws_iam_role.version_checker_api_gateway_cloudwatch_role.arn}"
}

resource "aws_cloudwatch_log_group" "lambdaversioncheck-api-log-group" {
  name              = "/aws/apigateway/${var.app_prefix}-API-Gateway-Execution-Logs/${var.stage_name}"
  retention_in_days = 7
}

resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  stage_name  = "${aws_api_gateway_deployment.lambdaversioncheck_deployment.stage_name}"
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50 
  }
}


resource "aws_api_gateway_request_validator" "lambda_version_check_validator" {
  name                        = "${var.app_prefix}-validator"
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  validate_request_body       = true
  validate_request_parameters = true
}


resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.version_checker_api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "POST"
  authorization = "NONE"
  depends_on    =  [ 
                    "aws_api_gateway_rest_api.version_checker_api",
                    "aws_api_gateway_resource.resource", 
                    "aws_api_gateway_request_validator.lambda_version_check_validator"
                  ]
}

resource "aws_api_gateway_integration" "integration" {
  type                    = "AWS"
  rest_api_id             = "${aws_api_gateway_rest_api.version_checker_api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_alias.lambda_function_alias_active.invoke_arn}"
  depends_on = ["aws_api_gateway_rest_api.version_checker_api","aws_api_gateway_resource.resource",
                "aws_api_gateway_method.method"]
  }
  

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
         "application/json" = "Empty"
    }
  depends_on = ["aws_api_gateway_resource.resource","aws_api_gateway_rest_api.version_checker_api",
                "aws_api_gateway_method.method"]
}


resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_200.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Requested-With'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
  }
   
  depends_on = ["aws_api_gateway_resource.resource","aws_api_gateway_rest_api.version_checker_api",
                 "aws_api_gateway_method_response.response_200","aws_api_gateway_method.method",
                 "aws_api_gateway_integration.integration"]
}

resource "aws_api_gateway_deployment" "lambdaversioncheck_deployment" {
  
  rest_api_id = "${aws_api_gateway_rest_api.version_checker_api.id}"
  stage_name  = "${var.stage_name}"

  depends_on = ["aws_api_gateway_integration.integration"]
}

output "deployment-url" {
  value = "${aws_api_gateway_deployment.lambdaversioncheck_deployment.invoke_url}"
}