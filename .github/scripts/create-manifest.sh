#!/bin/bash
# マルチアーキテクチャマニフェストを作成するスクリプト
# 使用方法: ./create-manifest.sh <image-base> <image-type> [version]
#   image-base: レジストリとリポジトリ名（例: ghcr.io/user/repo）
#   image-type: "app" または "db"
#   version: セマンティックバージョン（オプション、例: 1.0.0）

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "エラー: 引数が不足しています"
    echo "使用方法: $0 <image-base> <image-type> [version]"
    exit 1
fi

IMAGE_BASE="$1"
IMAGE_TYPE="$2"
VERSION="${3:-}"

if [ "$IMAGE_TYPE" = "db" ]; then
    IMAGE_BASE="${IMAGE_BASE}-db"
elif [ "$IMAGE_TYPE" != "app" ]; then
    echo "エラー: image-typeは 'app' または 'db' である必要があります"
    exit 1
fi

echo "=== マニフェスト作成開始 ==="
echo "イメージ: ${IMAGE_BASE}"

docker buildx imagetools create -t "${IMAGE_BASE}:latest" \
    "${IMAGE_BASE}:latest-amd64" \
    "${IMAGE_BASE}:latest-arm64"
echo "✓ latest マニフェスト作成完了"

if [ -n "$VERSION" ]; then
    docker buildx imagetools create -t "${IMAGE_BASE}:${VERSION}" \
        "${IMAGE_BASE}:${VERSION}-amd64" \
        "${IMAGE_BASE}:${VERSION}-arm64"
    echo "✓ ${VERSION} マニフェスト作成完了"

    MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1-2)
    docker buildx imagetools create -t "${IMAGE_BASE}:${MAJOR_MINOR}" \
        "${IMAGE_BASE}:${MAJOR_MINOR}-amd64" \
        "${IMAGE_BASE}:${MAJOR_MINOR}-arm64"
    echo "✓ ${MAJOR_MINOR} マニフェスト作成完了"
fi

echo "=== マニフェスト作成完了 ==="
