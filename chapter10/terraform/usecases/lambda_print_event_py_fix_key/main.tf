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
  s3_bucket     = local.lambda_asset.bucket
  // オブジェクトキーは固定値
  s3_key = local.lambda_asset.key
  // S3 オブジェクトから直接 sha256 ハッシュを求める
  source_code_hash = data.aws_s3_object.lambda_zip.checksum_sha256
  runtime          = "python3.12"
  // runtime が Python の場合は [ファイル名(拡張子除く)].[関数名] を指定
  handler       = "main.handler"
  architectures = ["arm64"]
  timeout       = 30
  role          = aws_iam_role.lambda_role.arn
}
