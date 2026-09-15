resource "aws_s3_bucket" "postgresql_back" {
  bucket = "postgresql-back"

  tags = {
    Name        = "postgresql_back"
    Environment = "nextcloud"
  }
}
