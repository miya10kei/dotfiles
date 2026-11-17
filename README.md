# dotfiles

![Docker Image CI](https://github.com/miya10kei/dotfiles/workflows/Docker%20Image%20CI/badge.svg)

個人用の開発環境設定ファイル（dotfiles）を管理するリポジトリ。

## 前提条件

- Docker
- `GITHUB_TOKEN` 環境変数

## セットアップ

```bash
# Docker開発環境のビルド（GITHUB_TOKENが必要）
export GITHUB_TOKEN=<your-token>
make build-dev-env

# dotfilesのデプロイ（Docker環境用）
# コンテナ起動時に .zshrc から自動で実行される。手で再実行するときは次のとおり
mise -C ~/.dotfiles dot apply --yes
```

配置は `mise.toml` の `[dotfiles]` と、その前後に走るフック（`[bootstrap.hooks]`）で定義している。個別に配置するときは対象を指定する。フックも毎回走るため、不要なら `--no-hooks` を付ける（例: `mise -C ~/.dotfiles --no-hooks dot apply ~/.config/nvim`）。
