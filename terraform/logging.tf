resource "aws_cloudwatch_log_group" "scrooge_destroy_log" {
  name              = "/aws/lambda/${aws_lambda_function.scrooge_destroy_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "scrooge_add_log" {
  name              = "/aws/lambda/${aws_lambda_function.scrooge_add_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
