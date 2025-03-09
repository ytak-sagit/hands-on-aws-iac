// NOTE:
// 子モジュールではバージョン下限を指定しておくと、
// ルートモジュールのバージョン記述のみを変更すれば良くなる
// -> バージョン変更に伴う影響範囲を小さくできる
terraform {
  required_version = ">=1.9.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.72.1"
    }
  }
}
