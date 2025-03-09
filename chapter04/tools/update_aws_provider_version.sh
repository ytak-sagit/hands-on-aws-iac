#!/bin/sh

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)

# 最新の AWS プロバイダのバージョンを取得
VERSION_TO="$(tfupdate release latest hashicorp/terraform-provider-aws)"

# env ディレクトリ配下のルートモジュールについて、最新の AWS プロバイダバージョンへ更新
tfupdate provider aws --recursive --version "${VERSION_TO}" "${ROOT_DIR}/env"
tfupdate lock --recursive --platform=linux_amd64 --platform=darwin_arm64 "${ROOT_DIR}/env"
