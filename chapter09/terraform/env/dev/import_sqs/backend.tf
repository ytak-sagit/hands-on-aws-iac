terraform {
  backend "s3" {
    bucket         = "dev-ytak-tfstate-aws-iac-book-project"
    key            = "import_sqs/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
