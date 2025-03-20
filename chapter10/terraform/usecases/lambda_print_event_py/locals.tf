locals {
  // アセットをアップロードした S3 バケット
  lambda_bucket      = "${var.stage}-ytak-lambda-deploy-ap-northeast-1"
  lambda_name        = "print_event_py"
  ssm_parameter_name = "/lambda_zip/${var.stage}/${local.lambda_name}"
}
