---
name: fetch-gmail
description: キーワードでGmailを検索し、メール一覧の表示と本文の確認を行う。「メールを検索して」「〇〇のメールを見たい」「〇〇からのメールを確認」「Gmailで〇〇を探して」「〇〇についてのメール」「受信トレイで〇〇」などユーザーがキーワードを伴ってメール検索・確認・閲覧を求めた場合は、必ずこのスキルを起動すること。キーワードがまだ示されていなくても、文脈からメール検索・閲覧の意図が読み取れる場合は積極的に起動すること。
---

# fetch-gmail

`gws` (Google Workspace CLI) でGmailを検索し、一覧表示・本文確認を行う。読み取り専用。`gws` は認証済みの前提。

スクリプトは `scripts/` にある。gws応答のパース・整形はすべてスクリプトが行い、Claudeはスクリプトの出力のみを読む。

## フロー

### 1. キーワード確定

未提供なら聞く。

### 2. 検索対象選択

AskUserQuestion で選ばせる。ユーザーが既に明示していればスキップ。

| 選択肢 | クエリ |
|--------|--------|
| 件名 | `subject:<KW>` |
| 差出人 | `from:<KW>` |
| 全文 | `<KW>` |

### 3. 検索+一覧表示

```bash
python3 <SKILL_DIR>/scripts/list_emails.py "<QUERY>" [max_results]
```

- gws呼び出し・メタデータ取得・スレッドグルーピングをすべて処理
- 出力にはスレッドID・メッセージIDが含まれる
- 0件の場合は別キーワード/検索対象を提案
- `max_results` デフォルト20。ユーザー要求なく拡大しない

### 4. 本文表示

デフォルトはスレッドの最新1通を表示する（引用チェーン込みで過去のやりとりも確認可能）。スレッド全体の時系列表示はユーザーが明示した場合のみ使用する。

```bash
# デフォルト: 最新1通（latest_id を使用）
python3 <SKILL_DIR>/scripts/read_email.py message <MESSAGE_ID>

# ユーザーが「スレッド全体を見たい」と言った場合のみ
python3 <SKILL_DIR>/scripts/read_email.py thread <THREAD_ID>
```

## エラーハンドリング

| 症状 | 対応 |
|------|------|
| `insufficient authentication scopes` | `gws auth login --services gmail --readonly` を依頼 |
| 認証エラー | `gws auth login` を依頼 |
| 0件 | 別キーワード提案 |
| base64 文字化け | `Content-Type` ヘッダのエンコーディング確認 |

## 制約

- 読み取り専用。送信・削除・ラベル変更は行わない
- メール本文のファイル保存・外部送信は行わない（機微情報）
