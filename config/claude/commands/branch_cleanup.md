---
description: マージ後のクリーンアップを実行する
---

## タスク

PRマージ後に、ベースブランチへの移動・更新とマージ済みブランチの削除を行う

worktree内かどうかで挙動を分岐する。

- 通常チェックアウト: mainブランチへ移動し、最新化してから作業ブランチを削除する
- worktree内: worktreeと同名のブランチへ戻り、origin/mainの最新へrebaseしてから作業ブランチを削除する

## 入力

ユーザーからの指示： $ARGUMENTS

## 手順

### 1. 現在のブランチを記録

```bash
git branch --show-current
```

削除対象となるマージ済みの作業ブランチ名として保持する。

### 2. worktree内かどうかを判定

`--git-dir` と `--git-common-dir` が異なる場合、linked worktree内にいると判定する。

```bash
test "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" && echo worktree || echo normal
```

- `normal` の場合は「手順A」へ
- `worktree` の場合は「手順B」へ

---

### 手順A: 通常チェックアウト時

#### A-1. mainブランチに移動

```bash
git checkout main
```

#### A-2. 最新の状態に更新

```bash
git pull origin main
```

#### A-3. 作業ブランチを削除

```bash
git branch -d <branch-name>
```

#### A-4. リモートの作業ブランチを削除（オプション）

```bash
git push origin --delete <branch-name>
```

---

### 手順B: worktree内の時

worktreeのトップ階層のディレクトリ名を、戻り先ブランチ名（例: `session1`）として扱う。

#### B-1. worktreeブランチ名を特定

```bash
basename "$(git rev-parse --show-toplevel)"
```

#### B-2. worktreeと同名のブランチへ戻る

作業ブランチからworktreeブランチへ切り替える。既にworktreeブランチにいる場合はスキップ。

```bash
git checkout <worktree-branch>
```

#### B-3. origin/mainの最新へrebase

```bash
git fetch origin
git rebase origin/main
```

#### B-4. 作業ブランチを削除

worktreeブランチと作業ブランチが異なる場合のみ削除する。

```bash
git branch -d <branch-name>
```

#### B-5. リモートの作業ブランチを削除（オプション）

```bash
git push origin --delete <branch-name>
```

## 出力

通常チェックアウト時:

```
✅ mainブランチに移動しました
✅ 最新の状態に更新しました
✅ ブランチ <branch-name> を削除しました
```

worktree内の時:

```
✅ worktreeブランチ <worktree-branch> に戻りました
✅ origin/main の最新へrebaseしました
✅ ブランチ <branch-name> を削除しました
```

## ルール

- マージ済みでないブランチは削除しない
- 強制削除（-D）は使用しない
- worktreeブランチ（戻り先）自体は削除しない
- rebaseでコンフリクトが発生した場合は、自動解決せずユーザーに報告して中断すること
- ユーザーからの指示がある場合は、その指示を最優先とすること
