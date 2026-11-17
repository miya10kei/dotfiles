# dotfiles

![Docker Image CI](https://github.com/miya10kei/dotfiles/workflows/Docker%20Image%20CI/badge.svg)

個人用の開発環境設定ファイル（dotfiles）を管理するリポジトリ。

## 前提条件

- Docker
- [mise](https://mise.jdx.dev/)（ホストで `mise trust ~/.dotfiles/mise.toml` を一度実行しておく）
- `GITHUB_TOKEN` 環境変数（イメージのビルド時）

## セットアップ

```bash
# Docker開発環境のビルド（GITHUB_TOKENが必要）
export GITHUB_TOKEN=<your-token>
mise -C ~/.dotfiles run build-dev-env

# dotfilesのデプロイ（Docker環境用）
# コンテナ起動時に .zshrc から自動で実行される。手で再実行するときは次のとおり
mise -C ~/.dotfiles dot apply --yes
```

配置は `mise.toml` の `[dotfiles]` と、その前後に走るフック（`[bootstrap.hooks]`）で定義している。個別に配置するときは対象を指定する。フックも毎回走るため、不要なら `--no-hooks` を付ける（例: `mise -C ~/.dotfiles --no-hooks dot apply ~/.config/nvim`）。

その他の作業は `mise.toml` の `[tasks]` に定義している。一覧は `mise -C ~/.dotfiles tasks ls` で確認できる。

## macOSホストの初期設定

```bash
# Homebrewとmiseを入れてから、caskなどをタスクで入れる
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install mise
mise trust ~/.dotfiles/mise.toml
mise -C ~/.dotfiles run brew-install
mise -C ~/.dotfiles run deploy-zsh
```
