resource "aws_s3_bucket" "bucket" {
  bucket = "supertux-ci-downloads"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  # TODO this seems like a silly policy, but it does effectively ignore index.html
  rule {
    id     = "Expiry"
    status = "Enabled"

    expiration {
      days = 15
    }
    
    filter {
      object_size_greater_than = 10485760 # 10 MB
    }
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "static/index.html"
  etag   = filemd5("static/index.html")
}