// Lambda 関数にアタッチする IAM ロールを記述
resource "aws_iam_role" "lambda_role" {
  name               = "${var.stage}-${local.lambda_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}
resource "aws_iam_role_policy_attachments_exclusive" "lambda_role_policy" {
  policy_arns = [data.aws_iam_policy.lambda_basic_execution.arn]
  role_name   = aws_iam_role.lambda_role.name
}

// Lambda 関数本体
resource "aws_lambda_function" "print_event" {
  function_name = "${var.stage}-${local.lambda_name}-tf"
  s3_bucket     = local.lambda_bucket
  // SSM パラメータストアから取得した sha256 ハッシュによってオブジェクトキーを指定
  s3_key  = nonsensitive("${local.lambda_name}/${data.aws_ssm_parameter.sha256.value}.zip")
  runtime = "python3.12"
  // runtime が Python の場合は [ファイル名(拡張子除く)].[関数名] を指定
  handler       = "main.handler"
  architectures = ["arm64"]
  timeout       = 30
  role          = aws_iam_role.lambda_role.arn
}
