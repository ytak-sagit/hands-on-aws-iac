locals {
  lambda_name           = "lambda_print_event_go"
  lambda_bucket         = "${var.stage}-ytak-lambda-deploy-ap-northeast-1"
  lambda_local_code_dir = abspath("${path.module}/../../../lambda/print_event_go")
}
