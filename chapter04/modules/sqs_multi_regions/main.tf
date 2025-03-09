// 子モジュールの定義
// NOTE:
// 子モジュールの場合は provider ブロックの記述ができない。
// そのため、リージョンが異なる複数のリソースを記述したい場合、
// resource ブロックの provider 属性でリージョンを動的に指定する。

resource "aws_sqs_queue" "default_region" {
  name                       = "${var.stage}-${var.queue_name_suffix}-default-region"
  visibility_timeout_seconds = var.sqs_queue_visibility_timeout_seconds
  max_message_size           = 2048
}

resource "aws_sqs_queue" "another_region" {
  name                       = "${var.stage}-${var.queue_name_suffix}-another-region"
  visibility_timeout_seconds = var.sqs_queue_visibility_timeout_seconds
  max_message_size           = 2048
  provider                   = aws.another_region // ルートモジュール側で指定する
}
