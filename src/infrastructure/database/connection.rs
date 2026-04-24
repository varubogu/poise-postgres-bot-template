use sea_orm::{Database, DatabaseConnection, DbErr};

/// アプリケーション用DB接続を確立する
pub async fn connect() -> Result<DatabaseConnection, DbErr> {
    let url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL が .env.app に設定されていません");
    Database::connect(&url).await
}

/// マイグレーション用DB接続を確立する（admin権限）
pub async fn connect_admin() -> Result<DatabaseConnection, DbErr> {
    let url = std::env::var("ADMIN_DATABASE_URL")
        .expect("ADMIN_DATABASE_URL が .env.app に設定されていません");
    Database::connect(&url).await
}
