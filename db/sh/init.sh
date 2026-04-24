#!/bin/bash
set -e

echo "=========================================="
echo "Discord Bot データベース初期化開始"
echo "=========================================="

APP_DB_PASSWORD="${APP_DB_PASSWORD:-change_this_password}"
ADMIN_DB_PASSWORD="${ADMIN_DB_PASSWORD:-change_this_admin_password}"
DB_NAME="${DB_NAME:-bot_db}"
DB_USER="${DB_USER:-postgres}"

echo "データベース名: ${DB_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "DB初期化まで10秒待機..."
sleep 10

psql -v ON_ERROR_STOP=1 \
     -U "$DB_USER" \
     -d postgres \
     -v app_password="$APP_DB_PASSWORD" \
     -v admin_password="$ADMIN_DB_PASSWORD" \
     -v db_name="$DB_NAME" \
     -f "$SCRIPT_DIR/../sql/init.sql"

echo "=========================================="
echo "データベース初期化が正常に完了しました"
echo "=========================================="
