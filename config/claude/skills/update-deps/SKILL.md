---
name: update-deps
description: 任意のリポジトリで依存パッケージ（Gradle/Python/Node.js/Terraform/Docker/GitHub Actions/ランタイム等の全エコシステム）を最新化し、検証・PR作成・CI修正・置き換わるDependabot PRのクローズまで一貫して実行する。「依存を更新して」「ライブラリを最新にして」「dependabotをまとめて」などの依頼で使用すること。
---

# Update Dependencies

依存パッケージを最新化し、PRとして出荷するまでを実行する。
リポジトリ固有の情報（default ブランチ、検証コマンド）は決め打ちせず、Step 0 で対象リポジトリから読み取る。
*ワークフローは最後のStepまで実行しきること。*

## 入力

ユーザーの指示から次を読み取る。

- チケットID（例: `PAID-767`）: ブランチ名・コミット・PRに使う。無ければ現在のブランチ名から抽出する。それも無ければチケットなしで進め、ブランチは `chore/update-deps` とする
- 対象の限定（例: 「backend と Actions だけ」「フロントは除く」）: 指定されたものだけを更新する。指示が無ければ全エコシステムを対象にする

## ワークフロー

### Step 0: リポジトリの把握

推測で進めず、次を読んで事実を確認する。

1. default ブランチ: `gh repo view --json defaultBranchRef`
2. 構成と規約: ルートおよび各ディレクトリの `CLAUDE.md`・`AGENTS.md`・`.claude/rules/`
3. 検証コマンド: 次の順に探し、見つかったものを採用する
   1. プロジェクトスコープのレビュー用スキル（`.claude/skills/*code-inspect*` 等）に書かれたコマンド
   2. タスクランナー（`mise.toml` の tasks、`Makefile`、`package.json` の scripts、`lefthook.yml`）
   3. CI のワークフロー（`.github/workflows/*`）で実行しているコマンド

### Step 1: 棚卸し

更新対象を洗い出し、「現在 → 最新」の一覧表を作る。`.github/dependabot.yml` があれば対象ディレクトリと突き合わせて漏れを防ぐ。

| エコシステム | 確認対象 |
|---|---|
| Gradle / Maven | version catalog（`libs.versions.toml`）、`build.gradle(.kts)`、`pom.xml`、Wrapper |
| Python | `pyproject.toml`、`requirements*.txt`、ロックファイル |
| Node.js | 全 `package.json`（workspace 含む）、ロックファイル |
| Terraform | `required_providers`、`required_version`、`.terraform-version`、`.terraform.lock.hcl` |
| Docker | 全 `Dockerfile` の `FROM`、compose のイメージ |
| GitHub Actions | `.github/workflows/*` と composite action の `uses:`、ワークフロー内で版を固定したツール |
| ランタイム・ツール | `mise.toml`・`.tool-versions`・`.python-version`・`.node-version` で版を固定したもの、Lambda runtime |

- 最新版は公式のリリース情報（パッケージレジストリ、`gh release list` 等）で確認する
- バージョンの比較は必ずバージョン順ソートで行う（文字列ソートだと新しい版を見落とす）
- `latest` 指定のものは更新対象外とする
- メジャーアップデートは破壊的変更を確認し、一覧表に明記する。コード修正が大きい場合はユーザーに確認する

### Step 2: ブランチ作成

既にフィーチャーブランチにいる場合はスキップ

/branch_create を実行（type は `chore`、チケットIDを渡す。例: `chore/PAID-767`。base は Step 0 で確認した default ブランチを指定する）

### Step 3: 更新

- リポジトリ既存のバージョン指定スタイル（タグ / SHAピン、`^` / 固定）を踏襲する
- ロックファイルも再生成する
- 依存の更新に伴う最小限のコード修正のみ行い、無関係なリファクタリングはしない

### Step 4: 検証

更新した対象ごとに Step 0 で見つけた検証コマンドを実行し、すべて通るまで修正する。依存更新は影響範囲が広いため、unit だけでなく integration テストも含めて実行する。

対象リポジトリにコマンドが見つからない対象は、次を目安にする。

| 対象 | 目安 |
|---|---|
| GitHub Actions | `actionlint` |
| Terraform | `terraform fmt -check` と `terraform validate` |
| Docker | 変更したイメージを `docker build` |

- Gradle: メモリ不足でデーモンが落ちる場合は `GRADLE_OPTS="-Xmx4g"` や `--no-daemon` を使う。広いパターンの `pkill` は自分のシェルを巻き込むため使わない
- テストが落ちたら1回だけ再実行し、再現する場合のみ原因を調査する
- Lambda: パッケージの展開後サイズが上限（250MB）未満か確認する。超える場合は軽量版パッケージ（例: `litellm` → `litellm-core`）を検討する
- TLS/CA エラー（certifi 等）が出ていないか確認する

### Step 5: コミット

/commit を実行（エコシステムごとにコミットを分ける）

### Step 6: PR作成

/pr を実行

- push・PR作成・auto-merge は1コマンドにまとめず、別々に実行する（まとめると権限確認で拒否される）
- PR本文に Step 1 の一覧表（現在 → 更新後、メジャー更新の有無）を含める

### Step 7: CI監視 & 修正

/ci_check を実行

失敗時は修正して再度 /ci_check を実行（成功するまで繰り返し、最大5回）

5回失敗したらユーザーに報告して中断

### Step 8: Dependabot PR のクローズ

今回のPRがマージ済みの場合のみクローズする。PRが却下・作り直しになった場合に更新が失われるのを防ぐため。

```bash
gh pr view --json state
```

- `MERGED`: 以下の手順でクローズする
- `OPEN`: クローズせず、クローズ予定の PR 一覧を完了報告に記載する（マージ後に再度このStepを依頼してもらう）

1. オープン中の Dependabot PR を取得する

   ```bash
   gh pr list --author app/dependabot --state open --json number,title,headRefName
   ```

2. 今回のPRで同等以上のバージョンに更新したパッケージの PR だけをクローズする

   ```bash
   gh pr close <number> --comment "#<今回のPR番号> で更新済みのためクローズします"
   ```

3. 今回の対象外や、今回より新しいバージョンを提案している PR は残し、完了報告に記載する

## 完了報告

- PR URL と CI 結果
- 更新したパッケージ一覧（メジャー更新は明示）
- 更新を見送ったパッケージとその理由
- クローズした / クローズ予定 / 残した Dependabot PR
