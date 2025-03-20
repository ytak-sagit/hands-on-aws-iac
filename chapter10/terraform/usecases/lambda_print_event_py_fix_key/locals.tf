locals {
  lambda_name = "print_event_py"
  lambda_asset = {
    bucket = "${var.stage}-ytak-lambda-deploy-ap-northeast-1"
    // S3 バケットのオブジェクトキー名は固定とする
    key = "lambda_${local.lambda_name}/lambda.zip"
  }
}
