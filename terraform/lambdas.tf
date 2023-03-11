locals {
  lambda_destroy_timeout = 60 * 3
  lambda_add_timeout     = 15
  lambda_common_envs     = {
    S3_BUCKET    = aws_s3_bucket.scrooge_resources_bucket.bucket
    IAM_ROLE_ARN = aws_iam_role.lambda_role.arn
  }
}

resource "aws_lambda_function" "scrooge_destroy_lambda" {
  function_name    = "${local.prefix}-destroy"
  image_uri        = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
  source_code_hash = data.aws_ecr_image.scrooge_image.image_digest
  package_type     = "Image"
  role             = aws_iam_role.lambda_role.arn
  timeout          = local.lambda_destroy_timeout
  environment {
    variables = merge(local.lambda_common_envs, {
      MODE = "destroy"
    })
  }

  vpc_config {
    security_group_ids = [local.vpc_default_security_group]
    subnet_ids         = local.platform_subnet_ids
  }
  replace_security_groups_on_destroy = true

  file_system_config {
    arn              = local.terraform_plugin_cache_efs_access_point
    local_mount_path = "/mnt/projects"
  }

  depends_on = [null_resource.scrooge_image_push]
}

resource "aws_lambda_function" "scrooge_add_lambda" {
  function_name    = "${local.prefix}-add"
  filename         = data.archive_file.scrooge_bin_archive.output_path
  handler          = local.project
  runtime          = "go1.x"
  source_code_hash = data.archive_file.scrooge_bin_archive.output_sha
  role             = aws_iam_role.lambda_role.arn
  timeout          = local.lambda_add_timeout

  environment {
    variables = local.lambda_common_envs
  }
}

resource "aws_lambda_function_url" "scrooge_add_invoke_url" {
  function_name      = aws_lambda_function.scrooge_add_lambda.function_name
  authorization_type = "AWS_IAM"
}
