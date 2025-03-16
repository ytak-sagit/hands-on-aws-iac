# 既存リソースをインポートするための「箱」を用意
# -> chapter09/terraform/usecases/import_sqs/main.tf へインポート結果を移管

# 子モジュールを参照
module "sqs" {
  source = "../../../usecases/import_sqs"
}
