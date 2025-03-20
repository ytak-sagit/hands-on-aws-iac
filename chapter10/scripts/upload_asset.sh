#!/bin/sh

set -e

# Lambda関数の名前
LAMBDA_NAME=${1:?}
# アセットとしてアップロードするZIPファイル名
# NOTE: deterministic-zip を使い、同じファイルで構成される場合は同じバイト列を返すようにすること
ZIPFILE_INPUT=${2:?}
# 環境名(dev, stg, prd, etc.)
STAGE=${3:-dev}

# アセットのアップロード先 S3 バケット
# NOTE: 一意な名前となるようにすること
S3_BUCKET="${STAGE}-ytak-lambda-deploy-ap-northeast-1"

SHA256HASH=$(sha256sum "${ZIPFILE_INPUT}" | cut -d ' ' -f 1)

ZIPFILE_BASENAME="${SHA256HASH}.zip"
set +e
# オブジェクトが存在しているか確認
aws s3api head-object --bucket "${S3_BUCKET}" --key "${LAMBDA_NAME}/${ZIPFILE_BASENAME}" > /dev/null 2>&1
RETURN_CODE=$?
set -e

if [ ${RETURN_CODE} -eq 0 ]; then
  # すでにオブジェクトが存在している場合はアップロード不可
  echo "The object s3://${S3_BUCKET}/${LAMBDA_NAME}/${ZIPFILE_BASENAME} already exists."
  echo "Failed to upload the zip file to S3."
  exit 1
elif [ ${RETURN_CODE} -ne 254 ]; then
  # オブジェクトが存在しない場合はリターンコード=254
  # それ以外の場合のエラー処理をここで実施
  echo "Failed to check the existence of the object s3://${S3_BUCKET}/${LAMBDA_NAME}/${ZIPFILE_BASENAME}."
  exit 1
fi

aws s3 cp "${ZIPFILE_INPUT}" "s3://${S3_BUCKET}/${LAMBDA_NAME}/${ZIPFILE_BASENAME}"

# SSMパラメータストアにSHA256ハッシュを登録
aws ssm put-parameter --name "/lambda_zip/${STAGE}/${LAMBDA_NAME}" --value "${SHA256HASH}" --type String --overwrite

exit 0
