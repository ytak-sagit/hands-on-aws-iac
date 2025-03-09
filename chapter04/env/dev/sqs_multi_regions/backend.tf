// tfstate ファイルの格納先（バックエンド）の定義
// NOTE: Terraform で AWS リソースを管理する際は、格納先を S3 とするのが一般的

terraform {
  backend "s3" {
    // NOTE: S3 バケット名はグローバルで一意である必要がある（他のユーザとも重複できない）
    bucket = "dev-tfstate-aws-iac-book-project"
    key    = "sqs_multi_regions/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
