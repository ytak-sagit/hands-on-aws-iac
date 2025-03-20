#!/bin/sh

#****************************************
# Input:
#   以下のような JSON
#     {
#       "lambda_local_code_dir": "[Lambda関数のコードが置かれたパス]",
#       "lambda_name": "[Lambda関数の名前]",
#       "method": "DOCKER", # または "LOCAL"
#       "dockerfile": "Dockerfile.build"
#     }
#
#---
# Output:
#   以下のような JSON
#     {
#       "zipfile": "[ZIPファイルのパス]"
#     }
#
#****************************************

set -e

eval "$(jq -r '@sh "LAMBDA_LOCAL_CODE_DIR=\(.lambda_local_code_dir) LAMBDA_NAME=\(.lambda_name) METHOD=\(.method) DOCKERFILE=\(.dockerfile)"')"

PLATFORM="linux/arm64"
OUTPUT_DIR="$(pwd)"/tf.out
TMP_ZIP_FILE="${OUTPUT_DIR}/${LAMBDA_NAME}.zip"

mkdir -p "${OUTPUT_DIR}/asset"
rm -rf "${OUTPUT_DIR}/asset/*"
rm -f "${TMP_ZIP_FILE}"

cd "${LAMBDA_LOCAL_CODE_DIR}" || exit 1

rm -rf "${OUTPUT_DIR}/asset"

# アセット作成
case "${METHOD}" in
  "LOCAL")
    mkdir -p "${OUTPUT_DIR}/asset"
    cp -r . "${OUTPUT_DIR}/asset"
    ;;
  "DOCKER")
    IMAGE="${LAMBDA_NAME}"
    docker build -t "${IMAGE}" --platform "${PLATFORM}:-linux/arm64}" -f "${DOCKERFILE}" .
    CONTAINER_ID=$(docker create "${IMAGE}")
    docker cp "${CONTAINER_ID}:/asset" "${OUTPUT_DIR}"
    docker rm -v "${CONTAINER_ID}" > /dev/null
    ;;
  *)
    echo "METHOD must be either DOCKER or LOCAL"
    exit 1
    ;;
esac

# 作成されたアセットをアーカイブ
(cd "${OUTPUT_DIR}/asset" && deterministic-zip -q -r "${TMP_ZIP_FILE}" .)

# 作成されたZIPファイルのsha256ハッシュを計算し、ファイル名を変更
SHA256HASH=$(sha256sum "${TMP_ZIP_FILE}" | cut -d ' ' -f 1)
ASSET_ZIPFILE="${OUTPUT_DIR}/${LAMBDA_NAME}/${SHA256HASH}.zip"
mkdir -p "$(dirname "${ASSET_ZIPFILE}")"
mv "${TMP_ZIP_FILE}" "${ASSET_ZIPFILE}"

jq -n --arg zipfile "${ASSET_ZIPFILE}" '{"zipfile":$zipfile}'

exit 0
