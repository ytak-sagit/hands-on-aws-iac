#!/bin/sh

# ---
# ルートモジュールのリソースのアドレスを子モジュールのものへ一括変換するスクリプト
# ---

set -evx

export AWS_PROFILE=xxx # NOTE: xxx は実際の値へ置き換えること
TO_PREFIX=$1
TARGET_LIST=$(terraform state list)

for TARGET in ${TARGET_LIST}
do
  terraform state mv "${TARGET}" "${TO_PREFIX}.${TARGET}"
done
