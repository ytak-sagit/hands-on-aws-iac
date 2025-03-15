terraform {
  backend "s3" {
    bucket         = "dev-ytak-tfstate-aws-iac-book-project"
    key            = "ecs_flask_api/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
