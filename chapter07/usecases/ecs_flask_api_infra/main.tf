resource "aws_ecr_repository" "flask_api" {
  name = "${var.stage}-flask-api-tf"
}

resource "aws_ssm_parameter" "flask_api_correct_answer" {
  name  = "/flask-api-tf/${var.stage}/correct_answer"
  type  = "SecureString"
  value = "uninitialized"
  # 格納された値が変更されても無視する
  # NOTE: tfstate は実装のリソースの値に更新されるが、その差分が無視される挙動となる
  lifecycle {
    ignore_changes = [value]
  }
}