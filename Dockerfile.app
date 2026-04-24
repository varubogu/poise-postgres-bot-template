# ================================
# ビルドステージ
# ================================
FROM rust:1.93-bookworm AS builder

WORKDIR /build

# 依存関係キャッシング用にCargo関連ファイルとmigrationをコピー
COPY Cargo.toml Cargo.lock ./
COPY migration ./migration
COPY build.rs ./
COPY locales ./locales

# ダミーソースで依存関係をビルド（キャッシュ層として機能）
RUN mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release --bin discord_bot || true

RUN rm -rf src target/release/build/

# 実際のソースコードをコピーしてリビルド
COPY src ./src
RUN cargo build --release --bin discord_bot

# ================================
# ランタイムステージ
# ================================
FROM debian:bookworm-slim

# CA証明書をインストール（HTTPS通信に必要）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# セキュリティのため非rootユーザーで実行
RUN useradd -m -u 1001 botuser

WORKDIR /app

COPY --from=builder /build/target/release/discord_bot .
COPY locales ./locales

RUN chown -R botuser:botuser /app
USER botuser

CMD ["./discord_bot"]
