output "lambda_role" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_url" {
  value = aws_lambda_function_url.scrooge_add_invoke_url.function_url
}
