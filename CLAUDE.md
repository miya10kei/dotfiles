# dotfiles

## 必須要件: OS・アーキテクチャ非依存

macOS / Linux × arm64（Apple Silicon・aarch64）/ x86_64 のすべての組み合わせで動くこと。Dockerイメージもホストに合わせてarm64とamd64の両方でビルドされる。

- OSやアーキで処理が変わる箇所は `uname -s` / `uname -m` で分岐する（Makefileは既存の `OS` 変数、Dockerfileは `TARGETARCH`）
- ダウンロードURLやパッケージ名にアーキ（`aarch64`、`amd64` など）を直書きしない
- GNU/BSDで挙動が違うコマンド（`sed -i`、`date -d`、`readlink -f`、`grep -P` など）は、macOSのホスト側で動くコードで使わない。使うなら分岐する

## 反映の仕組み

- 実行環境はDockerの開発コンテナ（`miya10kei/devenv`）。ホストの `~/.dotfiles` をbind mountし、各設定は `Makefile.d/deploy.mk` の `deploy-<tool>` が `ln -fns $(DOTDIR)/...` でsymlinkする
- コンテナのPID 1のzshが起動時に `make --always-make setup4d` を実行する。新しい `deploy-<tool>` を追加したら `Makefile` の `setup4d` にも加えること
- `config/mise` と `config/nvim` はイメージのビルド時にCOPYされる。ツールを追加しても `make build-dev-env` で再ビルドするまで入らない
- `data-volume/` は永続化用の実データ（gitignore対象）。設定ファイルを置かないこと

## 誤解しやすい箇所

- `config/claude/` はこのリポジトリ用ではなく、全プロジェクト共通のユーザー設定（`CLAUDE_CONFIG_DIR=~/.config/claude`）。このリポジトリ専用の指示は `./CLAUDE.md` か `./.claude/` に置くこと
- `.gitignore` は `.claude/*` を無視し、`settings.json` だけを除外している。`.claude/` 配下に別のファイルを追加するときは、除外ルールも追加すること
- git hookは `core.hooksPath` から `config/git/hooks/dispatch` 経由で実行される。lefthookの設定があるリポジトリでは、lefthookに委譲される

## 検証

- Makefile: `make -n deploy-<tool>` で実行内容を確認する（ファイルが既にあるターゲットはスキップされる）
- シェル: `zsh -n <file>`、`shellcheck <file>`
- Dockerfile: `hadolint Dockerfile`
- Markdown: `markdownlint-cli2 <file>`
- TOML: `taplo check`、YAML: `yamlfmt -lint`
