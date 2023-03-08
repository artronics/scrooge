locals {
  module_path = "${path.root}/../module"
}
module "scrooge" {
  source    = "../module"
  project   = local.project
  workspace = "default"
  resources = [
    {
      strategy = "s3:inactivity"
      id       = aws_s3_bucket.test-1.bucket
    }
  ]
}

resource "aws_s3_bucket" "test-1" {
  bucket = "${local.prefix}-test-1"
}

resource "aws_s3_bucket" "test-2" {
  bucket = "${local.prefix}-test-2"
}
