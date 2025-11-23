output "website_url" {
  description = "CloudFront URL for the website"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.website.bucket
}

output "certificate_validation" {
  description = "Add these DNS records to validate your ACM certificate"
  value       = aws_acm_certificate.website.domain_validation_options
}
