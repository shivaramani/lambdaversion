resource "aws_kinesis_stream" "lambda_version_checker_stream" {
  name             = "${var.app_prefix}-kinesis"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "dev"
  }
}