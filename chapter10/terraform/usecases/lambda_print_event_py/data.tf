// SSM パラメータストアの値を取得
data "aws_ssm_parameter" "sha256" {
  name = local.ssm_parameter_name
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
