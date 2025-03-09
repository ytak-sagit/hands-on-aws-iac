#!/bin/sh

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)

# 最新の Teraform バージョンを取得
VERSION_TO="$(tfupdate release latest hashicorp/terraform)"

# env ディレクトリ配下のルートモジュールについて、最新の Teraform バージョンへ更新
tfupdate terraform --recursive --version "${VERSION_TO}" "${ROOT_DIR}/env"
find "${ROOT_DIR}/env" -name ".terraform-version" -print0 | xargs -0 -I{} sh -c "echo ${VERSION_TO} > {}"
