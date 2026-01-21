---
description: マージ後のクリーンアップを実行する
---

## タスク

PRマージ後に、mainブランチへの移動とローカルブランチの削除を行う

## 入力

ユーザーからの指示： $ARGUMENTS

## 手順

### 1. 現在のブランチを記録

```bash
git branch --show-current
```

### 2. mainブランチに移動

```bash
git checkout main
```

### 3. 最新の状態に更新

```bash
git pull origin main
```

### 4. 作業ブランチを削除

```bash
git branch -d <branch-name>
```

### 5. リモートの作業ブランチを削除（オプション）

```bash
git push origin --delete <branch-name>
```

## 確認事項

- マージが完了していることを確認してから実行
- 未マージの変更がないことを確認
- 削除前にブランチ名を確認

## 出力

```
✅ mainブランチに移動しました
✅ 最新の状態に更新しました
✅ ブランチ <branch-name> を削除しました
```

## ルール

- マージ済みでないブランチは削除しない
- 強制削除（-D）は使用しない
- ユーザーからの指示がある場合は、その指示を最優先とすること
