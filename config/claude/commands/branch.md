---
description: フィーチャーブランチを作成する
---

## タスク

mainブランチから新しいフィーチャーブランチを作成する

## 入力

ユーザーからの指示： $ARGUMENTS

## 手順

1. 現在のブランチを確認（git branch --show-current）
2. mainブランチに移動（git checkout main）
3. 最新の状態に更新（git pull origin main）
4. 新しいブランチを作成して移動（git checkout -b <branch-name>）

## ブランチ命名規則

### 形式

```
<type>/<ticket-id>-<keyword>
```

### type一覧

| type | 用途 |
|------|------|
| feature | 新機能 |
| fix | バグ修正 |
| refactor | リファクタリング |
| docs | ドキュメント |
| chore | 雑務（依存関係更新など） |

### 例

```
feature/PROJ-123-login
fix/PROJ-456-auth
feature/add-validation
refactor/simplify-api
```

### ルール

- チケットIDがある場合は必ず含める
- チケットIDがない場合は、変更内容を表す適切なキーワードを使用
- keywordは短く、ケバブケース（kebab-case）で記述
- ユーザーからの指示がある場合は、その指示を最優先とすること
