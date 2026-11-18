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
    - sh・miseのタスク: `uname -s` / `uname -m`。`uname -m` はmacOSで `arm64`、Linuxで `aarch64` を返すので、両方を同じ値に正規化してから使う

## 反映の仕組み

- 実行環境は開発コンテナ（`miya10kei/devenv`）。ホストの `~/.dotfiles` をbind mountして設定を配置する
- コンテナのPID 1のzshが、起動時に `.zshrc` から `mise --cd ~/.dotfiles dotfiles apply` を実行する
- 配置はすべて `mise.toml` に定義する（`~/.config/mise` 自体も `[dotfiles]` で配置する）
    - 単純なsymlinkは `[dotfiles]` に追加する
    - コマンドの実行や `mise where` の結果が必要な配置、親子関係にあるtarget（例: `~/.config/gh` と `~/.config/gh/config.yml`。miseは同時に定義できない）は `[bootstrap.hooks.pre-dotfiles]` に書く。symlinkの配置後でないと動かないもの（例: `sheldon lock`）は `post-dotfiles` に書く
    - フックでは、ツールを `mise exec --` 経由で呼ばない。`exec_auto_install` が既定で有効で、起動のたびに未インストールのツールを入れようとするため。起動時は `.zshrc` が `mise activate` してから `dot apply` を呼ぶので、PATHから直接呼べる
- 手で実行する作業やホスト（macOS）向けの配置は `[tasks]` に書き、`mise -C ~/.dotfiles run <task>` で実行する。`[dotfiles]` とフックはコンテナ起動のたびに適用されるため、ホスト向けの配置を入れない
- `mise dot apply` は `--force` なしで実行しており、targetに実体のファイルやディレクトリがあると止まって起動時の配置が失敗する。イメージにCOPYされるものなど置き換えてよい実体は、`pre-dotfiles` で事前に消す（`~/.config/nvim` と同じ書き方）
- `config/mise` と `config/nvim` はイメージのビルド時にCOPYされる。ツールを追加しても `mise run build-dev-env` で再ビルドするまで入らない
- `data-volume/` は永続化用の実データ（gitignore対象）。設定ファイルを置かないこと

## パッケージの取得（サプライチェーン対策）

- uv・npm・miseは、公開から7日未満の版を入れない。設定は `config/uv/uv.toml` の `exclude-newer`、`config/npm/.npmrc` の `min-release-age`、`config/mise/config.toml` の `minimum_release_age`。パッケージマネージャーを追加するときも同じ制限をかける
- miseは `npm:` ツールをnpmではなく内蔵のaubeで入れるため、`.npmrc` の設定は効かない。npm側に設定があるからといって、mise側の設定を外さないこと
- 7日未満の版がどうしても必要なときは、設定を変えずにコマンドで一時的に外す（`mise install --minimum-release-age 0d <tool>`、`npm install --min-release-age=0`）
- PyPIとnpmの取得元はTakumi Guard（`pypi.flatt.tech`・`npm.flatt.tech`）。トークン `TAKUMI_GUARD_TOKEN` は `.zshrc` が `pass` から読む

## 誤解しやすい箇所

- `config/claude/` はこのリポジトリ用ではなく、全プロジェクト共通のユーザー設定（`CLAUDE_CONFIG_DIR=~/.config/claude`）。このリポジトリ専用の指示は `./CLAUDE.md` か `./.claude/` に置くこと
- `.gitignore` は `.claude/*` を無視し、`settings.json` と `skills/` だけを除外している。`.claude/` 配下に別のファイルを追加するときは、除外ルールも追加すること（`.claude/worktrees/` は無視したままにする）
- git hookは `core.hooksPath` から `config/git/hooks/dispatch` 経由で実行される。lefthookの設定があるリポジトリでは、lefthookに委譲される

## 検証

- コミット時に lefthook が、ステージしたファイルに lint をかける（対象と内容は `lefthook.yml`）。失敗したらコミットされないので、指摘を直してからコミットし直す
- dotfiles: `mise dot apply --dry-run` で配置内容とフックのコマンドを、`mise dot status` で適用状態を確認する（dry-runはフックを実行しない）
- 起動時の配置（`mise.toml`、`.zshrc`）を変えたら、実際のHOMEやdata-volumeでは試さず、リポジトリのコピーと一時HOMEで確かめる
    - `HOME=<一時HOME> mise -C <リポジトリのコピー> dot apply --yes` を2回実行し、origin/mainで同じことをした結果とHOME配下のsymlink・権限を比べる。一時HOMEには、イメージと同じく実体の `~/.config/mise` と `~/.config/nvim` を置いておく
    - `.zshrc` の起動処理まで確かめるときは、本番Dockerfileの最終段を最小化したイメージを作り、zshをPID 1で起動する
    - `mise where` と `sheldon` は、PATHの先頭に置いたスタブで置き換える
- シェル: `zsh -n <file>`、`shellcheck <file>`
- Dockerfile: `hadolint Dockerfile`
- Markdown: リポジトリのルートで `markdownlint-cli2 <file>` を実行する（設定はカレントディレクトリから探される）。指摘はファイル内の既存の書き方より優先して直し、入れ子の箇条書き（`-`・`*`）は4スペースでインデントする（番号付きリストの子は親の本文の位置に揃える）
- TOML: `taplo check`、YAML: `yamllint`、`yamlfmt -lint`
