#!/bin/sh
# シエル（miya10kei/ciel）が起動したworkerの状態の変化を、作業ごとのJSONLに1行ずつ追記する
# 対象は CIEL_TASK と CIEL_LOG_DIR が設定されたセッションだけ。それ以外のセッションでは何もしない
# 記録の失敗でworkerの作業を止めないよう、どの失敗でも exit 0 で抜ける

[ -n "${CIEL_TASK:-}" ] || exit 0
[ -n "${CIEL_LOG_DIR:-}" ] || exit 0
# ファイル名に使うので、worker名の規則（英小文字・数字・_・-）以外は受け付けない
case "$CIEL_TASK" in
    "" | *[!a-z0-9_-]*) exit 0 ;;
esac
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat) || exit 0
event_name=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null) || exit 0
log_file="$CIEL_LOG_DIR/$CIEL_TASK.jsonl"

last_event() {
    [ -f "$log_file" ] || return 0
    tail -n 1 "$log_file" | jq -r '.event // empty' 2>/dev/null
}

case "$event_name" in
    SessionStart) event=start ;;
    UserPromptSubmit) event=working ;;
    Notification)
        # 入力を待っているだけの通知（idle_prompt）は、Stopで記録済みなので書かない
        notification_type=$(printf '%s' "$input" | jq -r '.notification_type // empty' 2>/dev/null)
        [ "$notification_type" = idle_prompt ] && exit 0
        event=blocked
        ;;
    PostToolUse)
        # 許可の確認から作業に戻ったときだけ書く。ツールを実行するたびには書かない
        [ "$(last_event)" = blocked ] || exit 0
        event=working
        ;;
    Stop) event=idle ;;
    SessionEnd) event=end ;;
    *) exit 0 ;;
esac

mkdir -p "$CIEL_LOG_DIR" || exit 0
# date の %z は +0900 の形なので、ISO 8601 の +09:00 に直す
ts=$(date +%Y-%m-%dT%H:%M:%S%z | sed 's/\([+-][0-9][0-9]\)\([0-9][0-9]\)$/\1:\2/')
jq -cn --arg ts "$ts" --arg task "$CIEL_TASK" --arg event "$event" \
    '{ts: $ts, task: $task, event: $event, source: "hook"}' >>"$log_file" 2>/dev/null
exit 0
