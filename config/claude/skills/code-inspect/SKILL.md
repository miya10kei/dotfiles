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

### Step 2: コメント監査

Skill tool で `/comment-review` を実行し、今回の差分で追加・変更したコメントを監査する。
不要なコメントを残したままレビューに回すと、指摘が「本質的な問題」から逸れる。

### Step 3: コード簡易化

Agent tool で `subagent_type: "code-simplifier:code-simplifier"` を指定してサブエージェントを起動する。
コードの簡潔性・可読性を改善し、後続レビューの精度を上げるための前処理。

### Step 4: コードレビュー

以下を1つのメッセージで Agent tool を複数呼び出し、並列に実行する。
各サブエージェントのプロンプトには、レビュー対象の差分の範囲（ブランチ・ファイル）と変更概要を含めること。

Skill をサブエージェント内で実行させるもの:

- `/coderabbit:code-review`
- `/superpowers:requesting-code-review`
    - 実装内容・要件・変更概要をサブエージェントのプロンプトに含めて渡すこと
- `/security-review`

`subagent_type` を直接指定して起動するもの:

- `pr-review-toolkit:silent-failure-hunter`（エラーハンドリング・ログ漏れ検出）
- `pr-review-toolkit:pr-test-analyzer`（テストカバレッジのギャップ検出）
- `pr-review-toolkit:type-design-analyzer`（型設計・カプセル化評価）

差分に該当する対象がないレビューは省略してよい。
例: 型定義のない変更での type-design-analyzer、設定ファイルのみの変更での pr-test-analyzer。
省略した場合はその理由を Step 5 で報告すること。

### Step 5: レビュー結果の確認

Step 4 のレビュー結果をまとめ、ユーザーに提示する。

- **指摘がない場合** → ワークフロー完了
- **指摘がある場合** → AskUserQuestion で指摘一覧を提示し、各指摘の対応方針（修正する/修正しない/別の方針）をユーザーに確認する

### Step 6: 修正と再検査

Step 5 でユーザーが承認した修正を実施する。

修正完了後、**必ず Step 1 に戻り、Step 1 → Step 2 → Step 3 → Step 4 → Step 5 を実際に再実行する**。
「新規指摘は出ない」「軽微な修正だから不要」等の推測でスキップしてはならない。
指摘の有無は再実行した結果のみで判定すること。
