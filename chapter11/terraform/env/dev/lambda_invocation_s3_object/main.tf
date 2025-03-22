# Lambda 関数に付与する IAM ロール
resource "aws_iam_role" "lambda_exec" {
  name               = "put_s3_object_tf_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}
resource "aws_iam_role_policy_attachments_exclusive" "lambda_basic_role" {
  policy_arns = [data.aws_iam_policy.lambda_basic_role.arn]
  role_name   = aws_iam_role.lambda_exec.name
}
resource "aws_iam_role_policy" "lambda_inline_policy" {
  name   = "put_s3_object_lambda_policy_tf"
  policy = data.aws_iam_policy_document.put_s3_object_lambda_policy.json
  role   = aws_iam_role.lambda_exec.name
}

# Lambda 関数本体
resource "aws_lambda_function" "put_s3_object" {
  filename         = data.archive_file.put_s3_object_lambda_zip.output_path
  function_name    = "put_s3_object_tf"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.put_s3_object_lambda_zip.output_path)
  runtime          = "python3.12"
  timeout          = 10
}

# Lambda 関数を実行するためのリソース
# NOTE: このリソースの CRUD 時に Lambda 関数が実行される
resource "aws_lambda_invocation" "put_s3_object" {
  function_name = aws_lambda_function.put_s3_object.function_name
  input = jsonencode({
    resource_properties = {
      bucket = "${data.aws_caller_identity.current.account_id}-test-bucket"
      key    = "test-key-tf"
      body   = "Hello, World!"
    }
  })
  lifecycle_scope = "CRUD"
}
