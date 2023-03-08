data aws_iam_policy_document lambda_assume_role {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document lambda_s3 {
  statement {
    actions   = ["*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.scrooge_resources_bucket.bucket}/*"
    ]
  }
}

resource aws_iam_policy lambda_s3 {
  name        = "${local.prefix}-lambda-s3-permissions"
  description = "Contains S3 permissions for ${local.project} lambda"
  policy      = data.aws_iam_policy_document.lambda_s3.json
}

resource aws_iam_role lambda_role {
  name               = "${local.prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource aws_iam_role_policy_attachment lambda_s3 {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
