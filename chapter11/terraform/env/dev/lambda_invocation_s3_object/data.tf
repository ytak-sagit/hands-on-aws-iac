# Lambda 関数の ZIP アーカイブを作成する
data "archive_file" "put_s3_object_lambda_zip" {
  output_path = "./lambda_function.zip"
  source_file = "../../../lambda/put_s3_object/main.py"
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

# Lambda へ付与する S3 操作のための IAM ロール信頼関係ポリシー
data "aws_iam_policy_document" "put_s3_object_lambda_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}
