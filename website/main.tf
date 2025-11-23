provider "aws" {
  region = var.region
}

# ---------- S3 BUCKET (Private, no website hosting) ----------
resource "aws_s3_bucket" "website" {
  bucket = var.domain

  # Optional: Add tags for cost allocation
  tags = {
    Project     = "StaticWebsite"
    Environment = "Demo"
  }
}

# Block ALL public access (bucket is private; CloudFront accesses via OAI)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- CLOUDFRONT ----------
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${var.domain}"
}

# Bucket policy: allow ONLY CloudFront (via OAI) to read objects
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
}

# ACM Certificate (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "website" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = "StaticWebsite"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.bucket}"

    # Use S3 origin config (not custom!)
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100" # Most cost-effective

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Wait for policy and public access block to be applied
  depends_on = [
    aws_s3_bucket_policy.website,
    aws_s3_bucket_public_access_block.website
  ]

  tags = {
    Project = "StaticWebsite"
  }
}  
