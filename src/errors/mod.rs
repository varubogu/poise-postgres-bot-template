use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("データベースエラー: {0}")]
    Database(#[from] sea_orm::DbErr),

    #[error("Discordエラー: {0}")]
    Serenity(#[from] poise::serenity_prelude::Error),

    #[error("{0}")]
    Other(String),
}
