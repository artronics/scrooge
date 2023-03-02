resource "aws_dynamodb_table" "resources_to_scrooge" {
  name         = "scrooge_resources"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
