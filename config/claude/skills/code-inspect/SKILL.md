---
name: code-inspect
description: コード修正後の品質レビューをサブエージェントで実施する。コード修正、実装完了、バグ修正の後に使用すること。
---

# Code Inspect

コード修正後の品質を担保するため、チェックとレビューを実施する。
各レビューステップはサブエージェント（Agent tool）で実行し、メインコンテキストをクリーンに保つ。

## ワークフロー

### Step 1: チェック

以下を実施し、警告・エラーがあれば解消すること:

1. コードとコメント・ドキュメント（README.md等）の整合性確認
2. LSP Diagnostics
3. Lint・Formatter の実行

### Step 2: コード簡易化

Agent tool で `subagent_type: "code-simplifier:code-simplifier"` を指定してサブエージェントを起動する。
コードの簡潔性・可読性を改善し、後続レビューの精度を上げるための前処理。

### Step 3: コードレビュー

以下を別々のサブエージェントで実行する:

- Agent tool でサブエージェントを起動し、プロンプト内で `/coderabbit:code-review` を Skill tool で実行させる
- Agent tool でサブエージェントを起動し、プロンプト内で `/superpowers:requesting-code-review` を Skill tool で実行させる
    - 実装内容・要件・変更概要をサブエージェントのプロンプトに含めて渡すこと
- Agent tool でサブエージェントを起動し、プロンプト内で `/security-review` を Skill tool で実行させる
- Agent tool でサブエージェントを起動し、以下を Skill tool で並列実行させる:
    - `/pr-review-toolkit:silent-failure-hunter`（エラーハンドリング・ログ漏れ検出）
    - `/pr-review-toolkit:test-analyzer`（テストカバレッジのギャップ検出）
    - `/pr-review-toolkit:type-design-analyzer`（型設計・カプセル化評価）

### Step 4: レビュー結果の確認

Step 3 のレビュー結果をまとめ、ユーザーに提示する。

- **指摘がない場合** → ワークフロー完了
- **指摘がある場合** → AskUserQuestion で指摘一覧を提示し、各指摘の対応方針（修正する/修正しない/別の方針）をユーザーに確認する

### Step 5: 修正と再検査

Step 4 でユーザーが承認した修正を実施する。

修正完了後、**必ず Step 1 に戻り、Step 1 → Step 2 → Step 3 → Step 4 を実際に再実行する**。
「新規指摘は出ない」「軽微な修正だから不要」等の推測でスキップしてはならない。
指摘の有無は再実行した結果のみで判定すること。
