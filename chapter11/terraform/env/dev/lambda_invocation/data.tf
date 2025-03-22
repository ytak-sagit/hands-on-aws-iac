# Lambda 関数の ZIP アーカイブを作成する
data "archive_file" "print_event_lambda_zip" {
  output_path = "./lambda_function.zip"
  source_file = "../../../lambda/print_event/main.py"
  type        = "zip"
}

# Lambda 関数に割り当てる IAM ロール信頼関係ポリシー
data "aws_iam_policy_document" "lambda_exec_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
data "aws_iam_policy" "lambda_basic_role" {
  name = "AWSLambdaBasicExecutionRole"
}
