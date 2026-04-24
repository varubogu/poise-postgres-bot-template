use poise::serenity_prelude as serenity;
use sea_orm::DatabaseConnection;
use sea_orm_migration::MigratorTrait;
use tracing::info;

mod commands;
mod errors;
mod infrastructure;
mod repository;
mod services;

pub struct Data {
    pub db: DatabaseConnection,
}

pub type Error = errors::AppError;
pub type Context<'a> = poise::Context<'a, Data, Error>;

#[tokio::main]
async fn main() {
    // .env.app ファイルの読み込み
    dotenv::from_filename(".env.app").ok();
    dotenv::dotenv().ok();

    // トレーシング初期化
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::from_default_env()
                .add_directive(tracing::Level::INFO.into()),
        )
        .init();

    info!("Discord Bot 起動中...");

    let token = std::env::var("DISCORD_TOKEN").expect("DISCORD_TOKEN が設定されていません");
    let intents = serenity::GatewayIntents::non_privileged();

    // マイグレーション用DB接続
    let admin_db = infrastructure::database::connection::connect_admin()
        .await
        .expect("アドミンDB接続失敗");

    // マイグレーション実行
    info!("マイグレーション実行中...");
    migration::Migrator::up(&admin_db, None)
        .await
        .expect("マイグレーション失敗");
    info!("マイグレーション完了");

    // アプリ用DB接続
    let db = infrastructure::database::connection::connect()
        .await
        .expect("DB接続失敗");

    let framework = poise::Framework::builder()
        .options(poise::FrameworkOptions {
            commands: vec![commands::ping::ping()],
            ..Default::default()
        })
        .setup(|ctx, _ready, framework| {
            Box::pin(async move {
                info!("コマンドをグローバル登録中...");
                poise::builtins::register_globally(ctx, &framework.options().commands).await?;
                info!("Bot 起動完了");
                Ok(Data { db })
            })
        })
        .build();

    let mut client = serenity::ClientBuilder::new(token, intents)
        .framework(framework)
        .await
        .expect("Discordクライアント作成失敗");

    client.start().await.expect("Bot実行エラー");
}
