#!/bin/sh

# ---
# モジュール内の初期ファイルを作成するスクリプト
# ---

TERRAFORM_VERSION="1.11.2"
AWS_PROVIDER_VERSION="5.72.1"
# S3 バケットの名前が重複しないようにするための接尾辞
BUCKET_SUFFIX="iac-book-project"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <stage> <module_name>"
  exit 1
fi

STAGE=$1 # modules, usecases, dev, stg, prd, ...
MODULE_NAME=$2

ROOT_DIR="$(pwd)"
BACKEND_BUCKET_NAME="${STAGE}-ytak-tfstate-aws-${BUCKET_SUFFIX}"

if [ "${STAGE}" = "modules" ] || [ "${STAGE}" = "usecases" ]; then
  MODULE_FLAG=1
  WDIR="${ROOT_DIR}/${STAGE}/${MODULE_NAME}"
  VERSION_OPERATOR=">="
else
  MODULE_FLAG=0
  WDIR="${ROOT_DIR}/env/${STAGE}/${MODULE_NAME}"
  VERSION_OPERATOR=""
fi

mkdir -p ${WDIR}
cd ${WDIR} || exit 1

# ルートモジュール、子モジュール共通で必要となる terraform.tf を作成
cat <<EOF > terraform.tf
terraform {
  required_version = "${VERSION_OPERATOR}${TERRAFORM_VERSION}"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${VERSION_OPERATOR}${AWS_PROVIDER_VERSION}"
    }
  }
}
EOF

# ルートモジュール内に .terraform-version, backend.tf, providers.tf を作成
if [ ${MODULE_FLAG} -ne 1 ]; then
  cat <<EOF > .terraform-version
${TERRAFORM_VERSION}
EOF

  cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket         = "${BACKEND_BUCKET_NAME}"
    key            = "${MODULE_NAME}/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
EOF

  cat <<EOF > providers.tf
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Terraform   = "true"
      STAGE       = "${STAGE}"
      MODULE      = "${MODULE_NAME}"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Terraform   = "true"
      STAGE       = "${STAGE}"
      MODULE      = "${MODULE_NAME}"
    }
  }
}
EOF
fi

# ルートモジュール、子モジュール共通で必要となる各種ファイルを空で作成
touch main.tf
touch outputs.tf
touch locals.tf
touch data.tf

# 子モジュール内に .variables.tf を作成
if [ ${MODULE_FLAG} -eq 1 ]; then
  touch variables.tf
fi

echo "Files are created in ${WDIR}"
