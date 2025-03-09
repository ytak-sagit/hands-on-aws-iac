// 子モジュールの出力の定義

output "sqs_queue_url" {
  value = aws_sqs_queue.this.url
}
