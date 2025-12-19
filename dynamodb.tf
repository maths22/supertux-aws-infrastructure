resource "aws_dynamodb_table" "downloads" {
  name           = "supertux-downloads"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "url"
  range_key      = "branch"

  attribute {
    name = "url"
    type = "S"
  }

  attribute {
    name = "branch"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}