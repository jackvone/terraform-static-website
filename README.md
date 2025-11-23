# Static Website on AWS with Terraform

Deploys a secure, HTTPS-enabled static website using S3 + CloudFront.

## 🌐 Features
- Fully serverless (< $1/month estimated cost)
- HTTPS via AWS Certificate Manager (ACM)
- CloudFront CDN for global speed
- S3 bucket locked down (only accessible via CloudFront)

## 🚀 Deploy
1. Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. Configure AWS credentials (`aws configure`)
3. Initialize:
   ```sh
   terraform init
