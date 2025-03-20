data "aws_s3_object" "lambda_zip" {
  bucket        = local.lambda_asset.bucket
  key           = local.lambda_asset.key
  checksum_mode = "ENABLED"
}
