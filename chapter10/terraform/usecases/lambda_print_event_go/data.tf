// create_asset_zip.sh を external プロバイダが提供するデータソース external を使って実行する
// データソースなので、実行計画を作成するときに毎回作成される
data "external" "create_asset_zip" {
  program = ["sh", "${path.module}/../../../scripts/create_asset_zip.sh"]
  query = {
    lambda_local_code_dir = local.lambda_local_code_dir
    lambda_name           = local.lambda_name
    method                = "DOCKER"
    dockerfile            = "${local.lambda_local_code_dir}/Dockerfile.build"
  }
}

// IAM ロールの信頼関係ポリシーを記述
// AWS のサービス lambda.amazonaws.com に IAM ロールの引き受けを許可する
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// IAM ポリシー（AWSLambdaBasicExecutionRole）の情報を取得
data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}
