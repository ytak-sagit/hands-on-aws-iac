// ZIP ファイルの名前が変更されたら、ZIP ファイルを S3 にアップロードする
// リソースなので、terraform apply のときのみ実行される
resource "terraform_data" "upload_zip_s3" {
  provisioner "local-exec" {
    command = "aws s3 cp ${data.external.create_asset_zip.result.zipfile} s3://${local.lambda_bucket}/${local.lambda_name}/"
  }
  triggers_replace = [
    basename(data.external.create_asset_zip.result.zipfile),
  ]
}

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
  // データソース external で作成した ZIP ファイルを指定
  s3_key = "${local.lambda_name}/${basename(data.external.create_asset_zip.result.zipfile)}"
  // Go 言語で記述されたコードを使用する場合は provided.al2023 を指定
  runtime = "provided.al2023"
  // Go 言語で記述されたコードを使用する場合は bootstrap を指定
  handler       = "bootstrap"
  memory_size   = 128
  timeout       = 30
  role          = aws_iam_role.lambda_role.arn
  architectures = ["arm64"]
  depends_on    = [terraform_data.upload_zip_s3]
}
