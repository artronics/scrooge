locals {
  module_path = "${path.root}/../module"
}

module "scrooge" {
  source    = "../module"
  project   = local.project
  workspace = "default"
  resources = [
    {
      resource_address        = "aws_s3_bucket.${aws_s3_bucket.test-1-resource.bucket}"
      strategy                = "s3:inactivity"
      strategy_resource_id    = "${aws_s3_object.strategy_data.bucket}/${aws_s3_object.strategy_data.key}"
      expiry_duration_minutes = 1
    }
  ]
}

resource "aws_s3_bucket" "test-1-resource" {
  bucket = "${local.prefix}-test-2"
}

resource "aws_s3_bucket" "test_1_strategy" {
  bucket = "${local.prefix}-test-1"
}

resource "aws_s3_object" "strategy_data" {
  bucket       = aws_s3_bucket.test_1_strategy.bucket
  key          = "key_to_logs.txt"
  content      = "{}"
  content_type = "application/json"
}
