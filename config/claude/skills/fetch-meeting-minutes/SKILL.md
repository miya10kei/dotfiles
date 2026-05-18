---
name: fetch-meeting-minutes
description: Googleカレンダーの予定を検索し、そのmtgに紐づくGoogle Meetの議事録（Geminiによるメモ：サマリー＋文字起こし）をGoogle Docsからmarkdown形式でダウンロードする。「mtgの議事録を取ってきて」「会議の文字起こしが欲しい」「〇〇（キーワード）の議事録」「昨日のmtgのサマリーを保存して」などユーザーがmtgのキーワードを伴って議事録・サマリー・文字起こし・transcript・notes・Geminiメモを欲しがった場合は、必ずこのスキルを起動すること。キーワードがまだ示されていなくても、文脈からmtg議事録の取得意図が読み取れる場合は積極的に起動すること。
---

# fetch-meeting-minutes

ユーザーから渡されたキーワードに一致するGoogleカレンダーのmtgを特定し、そのmtgに紐づく Gemini ノート（Google Docs）を markdown としてダウンロードするためのスキル。

Google APIへのアクセスはすべて `gws` (Google Workspace CLI) を使用する。`gws` が認証済みで利用できる前提。

---

## 知っておくべき重要事実

このスキルの設計はこの事実に依存している。読み飛ばさないこと。

1. **Gemini のメモは1つの Google Docs に「サマリー」と「文字起こし」が同居している。** カレンダーイベントの `attachments[]` には通常「Gemini によるメモ」というタイトルのGoogle Docsが1件だけ入り、このファイルをmarkdownにエクスポートすると `# 📝 メモ`（サマリー）と `# 📖 文字起こし` の2セクションが1ファイルに連結されて出力される。したがってエクスポートは1回でよい。
2. **`gws drive files export --output` はカレントディレクトリ配下にしか書き出せない。** 絶対パスや `..` を含むパスを渡すと `"resolves to ... which is outside the current directory"` というバリデーションエラーになる。保存したいディレクトリに `cd` してから相対パスで実行すること。
3. **検索は `q` パラメータを使う。** 自前で `summary` を正規表現マッチするより Google 側の全文検索のほうが日本語でも安定する。`description` や `attendees` のメールアドレスも検索対象に含まれる。

---

## 全体の流れ

1. ユーザーからmtgのキーワードを受け取る（未提供なら聞く）
2. `gws calendar events list` でキーワードに一致するイベントを検索（デフォルト: 直近1週間）
3. 複数件ヒットした場合はユーザーに選択させる
4. 選ばれたイベントから Gemini ノートの `fileId` を取り出す
5. 保存先ディレクトリをユーザーに確認する
6. 保存先ディレクトリに `cd` し、`gws drive files export` で markdown として保存する
7. 結果を確認して報告する

---

## Step 1. キーワードの確定

ユーザーのメッセージにmtgを特定するためのキーワードが含まれていない場合、短く「どのmtgの議事録ですか？キーワードを教えてください（例: 定例、○○プロジェクト、1on1 など）」と尋ねる。

期間についてもユーザーが明示していなければデフォルト（直近1週間）で進め、1件もヒットしなかったときに期間を広げる提案をする。

---

## Step 2. カレンダー検索

直近1週間の範囲で全文検索する。`timeMin` と `timeMax` は RFC3339 UTC。

```bash
TIME_MIN=$(date -d '7 days ago' -u +"%Y-%m-%dT%H:%M:%SZ")
TIME_MAX=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

gws calendar events list --params "$(cat <<EOF
{
  "calendarId": "primary",
  "q": "<KEYWORD>",
  "timeMin": "$TIME_MIN",
  "timeMax": "$TIME_MAX",
  "singleEvents": true,
  "orderBy": "startTime",
  "maxResults": 20
}
EOF
)"
```

レスポンスの `items[]` から `id`, `summary`, `start.dateTime`, `attachments[]`, `htmlLink` を取り出す。

### 0件のとき

直近1週間で0件の場合は、「直近1週間では見つかりませんでした。期間を広げて検索しますか？（例: 直近1ヶ月）」とユーザーに提案する。勝手に期間を広げない。

---

## Step 3. イベントの選択

- **1件**: 「このmtgで合っていますか？: `<YYYY-MM-DD HH:MM> <summary>`」と1回確認
- **2件以上**: 番号付き一覧でユーザーに選ばせる

```
見つかったmtg:
  1. 2026-04-11 10:00  定例ミーティング
  2. 2026-04-09 15:00  定例/Aプロジェクト
  3. 2026-04-07 10:00  定例ミーティング

どの番号のmtgの議事録を取得しますか？
```

---

## Step 4. Gemini ノートの fileId 抽出

選ばれたイベントの `attachments[]` から、次の条件に合うものを探す:

- `mimeType == "application/vnd.google-apps.document"`
- `title` に「Gemini」または「メモ」または「Notes」が含まれる（ロケール差を吸収するため）

該当が1件だけならその `fileId` を採用する。複数該当したら番号付き一覧で選んでもらう。0件なら以下のように分岐する。

### Gemini ノートが見つからない場合

- `attachments` 自体が空 → まだ Gemini がメモを生成していないか、その mtg で Gemini ノート機能が有効化されていなかった可能性。`htmlLink` を提示して「カレンダーから直接確認してみてください」と案内して終了。
- Google Docs な添付はあるが Gemini ノートではない → ユーザーに一覧を見せて「このmtgではGeminiノートが見つかりませんでしたが、これらのDocが添付されています。どれかダウンロードしますか？」と尋ねる。

エラー扱いにはしない。議事録が存在しないケースは普通にありうる。

---

## Step 5. 保存先の確認

保存先を毎回ユーザーに確認する。候補として以下を提示する:

- カレントディレクトリ `./`
- `~/Downloads/`
- `~/Documents/meetings/`

ユーザーから指定があればそれを採用。議事録は機微情報を含むことが多いので、勝手にリポジトリ配下に置くなどはしない。

### ファイル名

衝突を避けるため以下の命名を推奨:

```
<YYYY-MM-DD>_<slugified-summary>.md
```

- 日付はイベントの `start.dateTime` の日付部分
- `slugified-summary` は `summary` から半角空白を `-` に、ファイル名に使えない記号（`/`, `:`, `\`, `*`, `?`, `"`, `<`, `>`, `|`）を除去したもの
- 日本語・記号の一部（「【】」など）はそのまま残してよい

例: `2026-03-31_【社内】IVR-論点議論.md`

---

## Step 6. markdown としてエクスポート

**重要: `gws drive files export --output` はカレントディレクトリ配下のみ書き込み可能。** 保存先ディレクトリに `cd` してから相対パスで指定すること。

```bash
cd "<保存先ディレクトリ>"
gws drive files export \
  --params '{"fileId": "<FILE_ID>", "mimeType": "text/markdown"}' \
  --output "<ファイル名>.md"
```

`mimeType` は必ず `text/markdown` を指定する（Google Docs API の公式サポート形式）。レスポンスに `"status": "success"` と `"bytes": <N>` が含まれれば成功。

---

## Step 7. 確認と報告

保存できたら以下を確認する:

- ファイルが実在し、サイズが 0 より大きいか
- 先頭数行を読んで内容が取れているか（Read ツールで L1-10 程度）
- `# 📝 メモ` と `# 📖 文字起こし` の両セクションが含まれているか（Grep で見出しを確認）

確認後、簡潔に報告する:

```
保存しました:
  ./2026-03-31_MTG.md (104 KB)
    - サマリー: 60行
    - 文字起こし: 1400行程度
```

---

## エラーハンドリング

| 症状 | 原因と対応 |
|------|----------|
| `Using keyring backend: keyring` のあとに認証系エラー | `gws auth login` をユーザーに依頼 |
| `resolves to ... outside the current directory` | 保存先に `cd` してから再実行（Step 6 参照） |
| `"error": { "code": 404 }` on export | ファイルIDが無効か、ユーザーにアクセス権がない |
| items が空（検索0件） | Step 2「0件のとき」参照 |

`gws` の stderr はそのままユーザーに見せて判断を仰いでよい。

---

## 設計メモ

- **1回のエクスポートで完結させる**: Gemini ノートは 1 Docs にサマリーと文字起こしが同居しているため、2回に分ける必要がない。ユーザーがサマリーだけ・文字起こしだけ欲しい場合は、後からファイルを2つに分割するなりエディタで切り出すなりできる。
- **期間を勝手に広げない**: デフォルト1週間で見つからなかったときに自動で拡張すると、古いmtgを誤って取ってくる事故が起きる。必ずユーザー確認を挟む。
- **attachment title のロケール非依存化**: 環境が英語UIの場合「Notes by Gemini」になる可能性があるため、「Gemini」「メモ」「Notes」の3キーワードでOR検索する。
