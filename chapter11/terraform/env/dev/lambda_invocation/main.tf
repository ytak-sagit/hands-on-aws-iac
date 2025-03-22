# Lambda 関数に付与する IAM ロール
resource "aws_iam_role" "lambda_exec" {
  name               = "print_event_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}
resource "aws_iam_role_policy_attachments_exclusive" "lambda_basic_role" {
  policy_arns = [data.aws_iam_policy.lambda_basic_role.arn]
  role_name   = aws_iam_role.lambda_exec.name
}

# Lambda 関数本体
resource "aws_lambda_function" "print_event" {
  filename         = data.archive_file.print_event_lambda_zip.output_path
  function_name    = "print_event_tf"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.handler"
  source_code_hash = filebase64sha256(data.archive_file.print_event_lambda_zip.output_path)
  runtime          = "python3.12"
  timeout          = 10
}

# Lambda 関数を実行するためのリソース
# NOTE: このリソースの CRUD 時に Lambda 関数が実行される
resource "aws_lambda_invocation" "print_event" {
  function_name = aws_lambda_function.print_event.function_name
  input = jsondecode({
    resource_properties = {
      greeting = "Hello, World!"
    }
  })
  lifecycle_scope = "CRUD"
}
