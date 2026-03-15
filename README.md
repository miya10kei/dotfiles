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
make setup4d
```

各設定は `make deploy-<tool>` で個別にデプロイ可能（例: `make deploy-nvim`）。
