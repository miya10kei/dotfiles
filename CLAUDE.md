# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

このリポジトリは個人用のdotfilesで、開発環境の設定ファイルとセットアップスクリプトを管理している。主にZsh、Neovim、tmux、Git、Claudeなどの設定が含まれる。

## 重要なコマンド

### セットアップ

```bash
# Docker開発環境のビルド
make build-dev-env

# dotfilesのデプロイ（Docker環境用）
make setup4d

# バイナリツールのインストール
make install4d
```

### 個別のデプロイ

各設定ファイルは個別にデプロイ可能：

```bash
make deploy-nvim          # Neovim設定
make deploy-git           # Git設定
make deploy-claude        # Claude設定
make deploy-zsh           # Zsh設定
make deploy-tmux          # tmux設定
make deploy-sheldon       # Sheldonプラグインマネージャー
```

### Neovim関連

```bash
make delete-nvimrc        # Neovim設定の削除
```

## アーキテクチャと構造

### ディレクトリ構成

- `Makefile.d/`: Makefileの分割定義
  - `deploy.mk`: 設定ファイルのシンボリックリンク作成
  - `bin.mk`: CLIツールのインストール定義（バージョン管理含む）
  - `nvim.mk`: Neovim関連のタスク
  - `mac.mk`: macOS固有のタスク

- `config/`: アプリケーション設定ファイル
  - `nvim/`: Neovim設定（Lua）
    - `lua/config/`: Neovim基本設定（keymaps, options, autocmd, lazy, session）
    - `lua/plugins/`: プラグイン設定（各プラグインごとに1ファイル）
    - `ftplugin/`: ファイルタイプ別設定
  - `sheldon/`: Zshプラグイン管理
  - `gh/`: GitHub CLI設定

- `claude/`: Claude Code関連
  - `settings.json`: Claude設定
  - `CLAUDE.md`: Claudeへの指示（グローバル方針）
  - `commands/`: カスタムコマンド
  - `install-mcp-servers.sh`: MCPサーバーインストールスクリプト

- `zshrc.d/`: Zsh設定の分割ファイル
  - `aliases.zsh`: エイリアス定義
  - `aws.zsh`: AWS関連設定
  - `docker.zsh`: Docker関連設定
  - `fzf.zsh`: fzf設定
  - `tmux.zsh`: tmux関連設定

- `data-volume/`: 永続化データ（認証情報、履歴など）
  - シンボリックリンクとして`$HOME`にマウントされる
  - Git管理対象外の機密情報を含む

### 設定ファイルのデプロイメカニズム

Makefileの`deploy-*`ターゲットは、dotfilesディレクトリ内のファイルを`$HOME`配下に**シンボリックリンク**として配置する。これにより：

1. dotfilesリポジトリを編集すれば即座に設定が反映
2. バージョン管理が容易
3. 複数マシン間での設定同期が簡単

### Docker開発環境

`Dockerfile`で完全な開発環境を構築：

- Ubuntu 24.04ベース
- アーキテクチャ別ビルド対応（x86_64/aarch64）
- 言語環境：Python, Node.js, Go, Rust, Lua, Haskellなど
- `.zshrc`内で`/.dockerenv`の存在をチェックし、Docker環境では自動的に`make setup4d`を実行

### Neovim設定の構造

- **プラグイン管理**: lazy.nvim（`config/lazy.lua`）
- **設定の分割**:
  - `config/options.lua`: エディタオプション
  - `config/keymaps.lua`: キーマッピング
  - `config/autocmd.lua`: 自動コマンド
  - `config/session.lua`: セッション管理（F5でセッション保存＆Neovim再起動）
- **プラグイン設定**: `lua/plugins/`内で各プラグインごとに独立したファイル
  - LSP: `lspconfig.lua`（11KB、大規模設定）
  - AI: `avante.lua`, `copilot.lua`, `claudecode.lua`
  - UI: `fzf-lua.lua`, `oil.lua`, `gruvbox.lua`

### 主要なインストールツール

`bin.mk`で管理されるCLIツール（バージョン指定あり）：

- シェル: sheldon, starship, zoxide
- Git: gh (GitHub CLI), ghq, delta
- 検索: fzf, ripgrep, fd
- その他: bat, jq, yq, navi, procs, exa, duf
- AWS: aws-cli, aws-vault, session-manager-plugin
- クラウド: gcloud

## 注意事項

### ファイル編集時

1. **シンボリックリンク**: デプロイ済み設定ファイル（`~/.zshrc`等）を直接編集しない。必ず`~/.dotfiles/`内の元ファイルを編集する
2. **Neovim設定**: `config/nvim/lua/plugins/`内のファイルは各プラグイン1ファイルで管理。関連設定を確認してから編集
3. **バージョン管理**: `Makefile.d/bin.mk`でツールのバージョンを一元管理。バージョンアップ時は変数を更新

### Git設定

- `.gitconfig`のcredential helperは`/root/.local/bin/gh`へのハードコードパスを使用
- commitテンプレートは`~/.gitmessage`を参照
- エディタはNeoVim（`nvim -c "set fenc=utf-8"`）

### 機密情報

`data-volume/`配下には以下が含まれる可能性があり、Git管理対象外：

- AWS認証情報
- Claude/Gemini認証
- GPG鍵
- パスワードストア
- Zsh履歴

## 開発パターン

### 新しいツールの追加

1. `Makefile.d/bin.mk`にバージョン変数とインストールターゲットを追加
2. `install-bins`のdependenciesに追加
3. 必要に応じて`Makefile.d/deploy.mk`に設定ファイルのデプロイターゲットを追加
4. `setup4d`のdependenciesに追加（Docker環境で自動セットアップする場合）

### Neovimプラグインの追加

1. `config/nvim/lua/plugins/`に新しいプラグイン設定ファイルを作成（例: `new-plugin.lua`）
2. lazy.nvimのプラグイン定義を記述
3. 必要に応じて`lua/config/keymaps.lua`にキーマッピング追加

### Zsh設定の追加

1. `zshrc.d/`に新しい`.zsh`ファイルを作成
2. `.zshrc`の該当セクションで`source`追加
