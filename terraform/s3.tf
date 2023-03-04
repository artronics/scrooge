resource "aws_s3_bucket" "scrooge_resources_bucket" {
  bucket = "${local.prefix}-resources"
}

resource "aws_s3_bucket_versioning" "scrooge_bucket_versioning" {
  bucket = aws_s3_bucket.scrooge_resources_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_object" "s3_resources_db" {
  bucket       = aws_s3_bucket.scrooge_resources_bucket.bucket
  key          = "db.json"
  content      = local.is_test ? file("${path.cwd}/test_db.json") : "[]"
  content_type = "application/json"
}
