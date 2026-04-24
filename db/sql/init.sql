-- ================================
-- Discord Bot データベース初期化スクリプト
-- ================================
-- 使用方法:
--   psql -v app_password="..." -v admin_password="..." \
--        -v db_name="bot_db" -f init.sql
-- ================================

-- アプリロール作成（既存の場合はスキップ）
\set ON_ERROR_STOP 0
CREATE ROLE app_user WITH LOGIN PASSWORD :'app_password';
\set ON_ERROR_STOP 1
ALTER ROLE app_user WITH LOGIN PASSWORD :'app_password';

-- アドミンロール作成（マイグレーション実行用）
\set ON_ERROR_STOP 0
CREATE ROLE admin_user WITH LOGIN PASSWORD :'admin_password';
\set ON_ERROR_STOP 1
ALTER ROLE admin_user WITH LOGIN PASSWORD :'admin_password';
ALTER ROLE admin_user WITH BYPASSRLS CREATEDB;

-- データベース作成
\set ON_ERROR_STOP 0
CREATE DATABASE :db_name WITH OWNER admin_user ENCODING 'UTF8';
\set ON_ERROR_STOP 1

\connect :db_name

-- 接続権限付与
GRANT CONNECT ON DATABASE :db_name TO app_user;
GRANT CONNECT ON DATABASE :db_name TO admin_user;

-- スキーマ作成権限（マイグレーション用）
GRANT CREATE ON DATABASE :db_name TO admin_user;

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Discord Bot データベース初期化完了';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ロール: app_user, admin_user';
    RAISE NOTICE '次のステップ: cargo run -- migrate';
    RAISE NOTICE '========================================';
END
$$;
