FROM mcr.microsoft.com/devcontainers/rust:1-bookworm

# lld リンカをインストール（ビルド高速化）
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
   && apt-get -y install clang lld \
   && apt-get autoremove -y && apt-get clean -y
