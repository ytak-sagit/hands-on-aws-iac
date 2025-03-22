terraform {
  backend "s3" {
    bucket         = "dev-ytak-tfstate-aws-iac-book-project"
    key            = "lambda_invocation_s3_object/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
