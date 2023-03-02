resource "aws_lambda_function" "scrooge_lambda" {
  function_name    = local.prefix
  image_uri        = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
  source_code_hash = data.aws_ecr_image.scrooge_image.image_digest
  package_type     = "Image"
  role             = aws_iam_role.iam_for_lambda.arn

  depends_on = [null_resource.scrooge_image_push]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.prefix}-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
