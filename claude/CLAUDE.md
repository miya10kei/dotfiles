# グローバル方針

## 基本ルール

- 思考は英語、応答は日本語で行うこと

## MCP

- AWSについての情報が必要な場合は、aws-knowledgeを使用すること
- Park Directの情報が必要な場合は、bedrock-knowledgeを使用すること
- Web検索をする場合は、gemini-cliを使用すること

## Pythonプロジェクトのルール

- コード修正後はフォーマッターとリンターを実行し、LSPの警告を解消すること
  - `uv run format && uv run check --fix`
- Pythonicなコードを心がけること
