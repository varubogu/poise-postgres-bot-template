use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20240101_000000_create_example_table"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Example::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Example::Id)
                            .uuid()
                            .not_null()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Example::Name).string().not_null())
                    .col(
                        ColumnDef::new(Example::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null(),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Example::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Example {
    Table,
    Id,
    Name,
    CreatedAt,
}
