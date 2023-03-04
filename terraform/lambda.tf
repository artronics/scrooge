resource "aws_lambda_function" "scrooge_lambda" {
  function_name    = local.prefix
  image_uri        = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
  source_code_hash = data.aws_ecr_image.scrooge_image.image_digest
  package_type     = "Image"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      S3_BUCKET    = aws_s3_bucket.scrooge_resources_bucket.bucket
      IAM_ROLE_ARN = aws_iam_role.lambda_role.arn
    }
  }

  depends_on = [null_resource.scrooge_image_push]

}
