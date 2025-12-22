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

  lifecycle {
    action_trigger {
      events = [after_create, after_update]
      actions = [
        action.aws_cloudfront_create_invalidation.invalidate_index
      ]
    }
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
			type        = "Service"
			identifiers = ["cloudfront.amazonaws.com"]
		}

		condition {
			test     = "StringLike"
			variable = "AWS:SourceArn"
			values   = [aws_cloudfront_distribution.distribution.arn]
		}
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}