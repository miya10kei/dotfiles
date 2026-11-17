# dotfiles

## 必須要件: OS・アーキテクチャ非依存

次の3環境すべてで動くこと。開発コンテナのイメージはホストのアーキでビルドされるため、linux/arm64とlinux/amd64の両方で動く必要がある。コンテナランタイムはDocker（Desktop・Engine）やRancher Desktopなど環境ごとに異なるため、特定のランタイムを前提にしない。

- macOS arm64（Apple Silicon）
- Linux arm64（aarch64）
- Linux x86_64

OSやアーキの違いは、次の優先順で吸収する。

1. 分岐を書かない。アーキの解決はツールに任せる
    - mise: aquaバックエンドを優先する。httpバックエンドは `{{ os() }}` / `{{ arch() }}` テンプレートか `platforms.<os>-<arch>` を使い、URLにアーキ名を直書きしない
    - Dockerfile: aptとマルチアーキのベースイメージを使う
2. OSではなく機能で判定する。コマンドの有無は `command -v`（zshは `(( $+commands[x] ))`）で確かめる。`rdctl` などランタイム固有のコマンドも同様に、存在を確かめてから使う。GNU/BSDで挙動が違うコマンド（`sed -i`、`date -d`、`readlink -f`、`grep -P` など）は、POSIXの範囲のオプションだけを使う
3. 分岐が避けられない場合は、場所ごとに次の値を使う
    - Dockerfile: `ARG TARGETARCH`（`amd64` / `arm64`）。`uname -m` はビルド対象ではなく実行環境を返すので使わない
    - zsh: `$OSTYPE`（`darwin*` / `linux*`）
    - sh・Makefile: `uname -s` / `uname -m`。`uname -m` はmacOSで `arm64`、Linuxで `aarch64` を返すので、両方を同じ値に正規化してから使う

## 反映の仕組み

- 実行環境は開発コンテナ（`miya10kei/devenv`）。ホストの `~/.dotfiles` をbind mountして設定を配置する
- コンテナのPID 1のzshが起動時に `make --always-make setup4d` を実行する
- 配置は `mise.toml` に定義し、`setup4d` の `deploy-dotfiles` が `mise dot apply` で適用する。`setup4d` でMakeに残っている配置は、`~/.config/mise` 自体を置く `deploy-mise` だけ
    - 単純なsymlinkは `[dotfiles]` に追加する
    - コマンドの実行や `mise where` の結果が必要な配置、親子関係にあるtarget（例: `~/.config/gh` と `~/.config/gh/config.yml`。miseは同時に定義できない）は `[bootstrap.hooks.pre-dotfiles]` に書く。symlinkの配置後でないと動かないもの（例: `sheldon lock`）は `post-dotfiles` に書く
    - フックでは、ツールを `mise exec --` 経由で呼ばない。`exec_auto_install` が既定で有効で、起動のたびに未インストールのツールを入れようとするため。起動時は `.zshrc` が `mise activate` してから `make` を呼ぶので、PATHから直接呼べる
- `mise dot apply` は `--force` なしで実行しており、targetに実体のファイルやディレクトリがあると止まって起動時の配置が失敗する。イメージにCOPYされるものなど置き換えてよい実体は、`pre-dotfiles` で事前に消す（`~/.config/nvim` と同じ書き方）
- `config/mise` と `config/nvim` はイメージのビルド時にCOPYされる。ツールを追加しても `make build-dev-env` で再ビルドするまで入らない
- `data-volume/` は永続化用の実データ（gitignore対象）。設定ファイルを置かないこと

## 誤解しやすい箇所

- `config/claude/` はこのリポジトリ用ではなく、全プロジェクト共通のユーザー設定（`CLAUDE_CONFIG_DIR=~/.config/claude`）。このリポジトリ専用の指示は `./CLAUDE.md` か `./.claude/` に置くこと
- `.gitignore` は `.claude/*` を無視し、`settings.json` だけを除外している。`.claude/` 配下に別のファイルを追加するときは、除外ルールも追加すること
- git hookは `core.hooksPath` から `config/git/hooks/dispatch` 経由で実行される。lefthookの設定があるリポジトリでは、lefthookに委譲される

## 検証

- dotfiles: `mise dot apply --dry-run` で配置内容とフックのコマンドを、`mise dot status` で適用状態を確認する（dry-runはフックを実行しない）
- 起動時の配置（`setup4d`、`mise.toml`）を変えたら、実際のHOMEやdata-volumeでは試さず、リポジトリのコピーと一時HOMEで確かめる
    - `make --always-make HOME=<一時HOME> DOTDIR=<リポジトリのコピー> setup4d` を2回実行し、origin/mainで同じことをした結果とHOME配下のsymlink・権限を比べる
    - `mise where` と `sheldon` は、PATHの先頭に置いたスタブで置き換える
- シェル: `zsh -n <file>`、`shellcheck <file>`
- Dockerfile: `hadolint Dockerfile`
- Markdown: リポジトリのルートで `markdownlint-cli2 <file>` を実行する（設定はカレントディレクトリから探される）。指摘はファイル内の既存の書き方より優先して直し、入れ子の箇条書き（`-`・`*`）は4スペースでインデントする（番号付きリストの子は親の本文の位置に揃える）
- TOML: `taplo check`、YAML: `yamlfmt -lint`
