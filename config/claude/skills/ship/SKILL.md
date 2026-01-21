---
name: ship
description: コード変更をブランチ作成からマージまで一貫して実行する
context: fork
---

# Ship Workflow

コード変更を本番にshipするための全ワークフローを実行します。

## 前提条件

- 変更がローカルに存在すること
- mainブランチが最新であること

## ワークフロー

### Step 1: ブランチ作成

1. mainブランチに移動して最新化
   ```bash
   git checkout main && git pull origin main
   ```

2. フィーチャーブランチを作成
   ```bash
   git checkout -b <type>/<ticket-id>-<description>
   ```

   - type: feature / fix / refactor / docs / chore
   - チケットIDがあれば含める
   - descriptionはケバブケースで簡潔に

### Step 2: コミット

1. 変更を確認
   ```bash
   git status && git diff
   ```

2. 論理単位でステージング & コミット
   - メッセージ形式: `<gitmoji> [TICKET-ID] <説明>`
   - gitmojiは変更内容に最も合うものを選択
   - 1つの論理的な変更ごとにコミット

### Step 3: PR作成

1. リモートにプッシュ
   ```bash
   git push -u origin <branch-name>
   ```

2. PRを作成
   ```bash
   gh pr create --title "<title>" --body "<body>"
   ```

3. auto-mergeを有効化
   ```bash
   gh pr merge --auto --squash
   ```

### Step 4: CI監視 & 修正

1. CI状態を確認
   ```bash
   gh pr checks
   ```

2. 失敗時の対応（成功するまで繰り返し、最大5回）
   - `gh run view <run-id> --log-failed` でログ取得
   - エラーを解析して修正
   - `🐛 fix: <内容>` でコミット & プッシュ
   - 再度CI状態を確認

3. 5回失敗したらユーザーに報告して中断

### Step 5: マージ確認

1. マージ状態を確認
   ```bash
   gh pr view --json state,mergedAt
   ```

2. auto-mergeが完了するまで待機

### Step 6: クリーンアップ

1. mainブランチに移動
   ```bash
   git checkout main
   ```

2. 最新化
   ```bash
   git pull origin main
   ```

3. 作業ブランチを削除
   ```bash
   git branch -d <branch-name>
   ```

## 完了報告

ワークフロー完了後、以下を報告:

- PR URL
- マージされたコミット
- 削除したブランチ名
