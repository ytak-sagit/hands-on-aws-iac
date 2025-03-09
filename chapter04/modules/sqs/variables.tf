// 入力パラメータの定義

variable "stage" {
  type        = string
  description = "環境名"
  // NOTE: default 指定がないため、このパラメータは指定必須
}

variable "queue_name_suffix" {
  type        = string
  description = "SQSキューの名前の接尾辞"
  // NOTE: default 指定がないため、このパラメータは指定必須
}

variable "sqs_queue_visibility_timeout_seconds" {
  type        = number
  default     = 30
  description = "SQSキューのメッセージの可視性タイムアウト"
}
