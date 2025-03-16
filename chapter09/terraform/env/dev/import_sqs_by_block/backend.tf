terraform {
  backend "s3" {
    bucket         = "dev-ytak-tfstate-aws-iac-book-project"
    key            = "import_sqs_by_block/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
