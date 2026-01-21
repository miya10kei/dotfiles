---
description: PRのマージ状態を確認する
---

## タスク

現在のPRがマージされたかどうかを確認する

## 入力

ユーザーからの指示： $ARGUMENTS

## 手順

### 1. PR状態確認

```bash
gh pr view --json state,mergedAt,mergeCommit
```

### 2. 状態に応じた対応

| state | 意味 | 対応 |
|-------|------|------|
| OPEN | 未マージ | 待機または確認 |
| MERGED | マージ済み | cleanup へ進む |
| CLOSED | クローズ（マージなし） | 理由を確認 |

### 3. auto-merge確認

```bash
gh pr view --json autoMergeRequest
```

- auto-mergeが有効か確認
- 無効なら有効化を提案

## 出力

- マージ済み: 「PR #XXX はマージされました」
- 未マージ: 「PR #XXX はまだマージされていません（state: OPEN）」
- CI待ち: 「PR #XXX はCIの完了を待っています」

## ルール

- ユーザーからの指示がある場合は、その指示を最優先とすること
