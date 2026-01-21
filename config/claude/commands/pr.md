---
description: Pull Requestを作成する
---

## タスク

現在のブランチからPull Requestを作成し、auto-mergeを有効化する

## 入力

ユーザーからの指示： $ARGUMENTS

## 手順

1. 現在のブランチを確認（git branch --show-current）
2. 未プッシュのコミットがあればプッシュ（git push -u origin <branch>）
3. PRを作成（gh pr create）
4. auto-mergeを有効化（gh pr merge --auto --squash）

## PRタイトル

### 形式

```
[TICKET-ID] <gitmoji> <説明>
```

### 例

```
[PROJ-123] ✨ ログイン機能を追加
[PROJ-456] 🐛 認証エラーを修正
```

### ルール

- ブランチ名からチケットIDを抽出して含める
- 変更内容に合ったgitmojiを付与
- 説明は簡潔に

## PR本文

### 形式

```markdown
## Summary
- 変更内容の要点（1-3行）
```

### ルール

- Summaryは変更の目的と内容を簡潔に
- 関連するIssueがあればリンク

## オプション

- `--draft`: ドラフトPRとして作成
- `--reviewer <user>`: レビュアーを指定
- ユーザーからの指示がある場合は、その指示を最優先とすること
