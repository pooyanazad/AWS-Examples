provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket_prefix = "random-bucket-" # This generates a unique name
  acl           = "private"

  tags = {
    Name        = "my-s3-buucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
  description = "The name of the S3 bucket"
}