resource "aws_s3_bucket" "cicd_bucket" {
  bucket = var.artifacts_bucket_name
  acl    = "private"
}