#!/usr/bin/env python3
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def main():
    # stdinからJSONデータを読み取る
    input_data = json.load(sys.stdin)
    hook_event = input_data.get("hook_event_name")

    # tmuxウィンドウ名の更新
    update_tmux_window_name(hook_event)

    # Stop Hookの場合のみ処理時間を計算
    if hook_event == "Stop":
        process_stop_hook(input_data)

    sys.exit(0)


def process_stop_hook(input_data):
    """Stop Hook時の処理時間計算とサウンド再生"""
    try:
        transcript_path = Path(input_data.get("transcript_path", "")).expanduser()

        if not transcript_path.exists():
            return

        last_user_timestamp = None
        last_assistant_timestamp = None

        # transcript.jsonlを読み込む
        with open(transcript_path, "r") as f:
            for line in f:
                if not line.strip():
                    continue
                entry = json.loads(line)

                # 最後の通常ユーザーメッセージのタイムスタンプ
                # （ツール実行結果ではないもの）
                if entry.get("type") == "user":
                    message = entry.get("message", {})
                    content = message.get("content", "")
                    # contentが文字列の場合のみ（ツール実行結果は配列）
                    if isinstance(content, str):
                        last_user_timestamp = entry.get("timestamp")

                # 最後のassistantメッセージのタイムスタンプ（常に更新）
                if entry.get("type") == "assistant":
                    last_assistant_timestamp = entry.get("timestamp")

        # 処理時間を計算
        if last_user_timestamp and last_assistant_timestamp:
            start_time = datetime.fromisoformat(
                last_user_timestamp.replace("Z", "+00:00")
            )
            end_time = datetime.fromisoformat(
                last_assistant_timestamp.replace("Z", "+00:00")
            )
            elapsed_seconds = (end_time - start_time).total_seconds()

            # 30秒を超えていたら音声再生
            if elapsed_seconds > 30:
                subprocess.run(
                    ["paplay", str(Path.home() / "Documents" / "work_done.wav")],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
    except Exception:
        pass  # エラーは無視


def update_tmux_window_name(hook_event):
    """Hook種別に応じてtmuxウィンドウ名を更新"""
    try:
        result = subprocess.run(
            ["tmux", "display-message", "-p", "#W"],
            capture_output=True,
            text=True,
            check=True,
        )
        current_name = result.stdout.strip()

        # Hook種別で絵文字を選択
        emoji = "🔵" if hook_event == "UserPromptSubmit" else "🟢"

        # 既存の絵文字を置き換え（または追加）
        new_name = re.sub(r"^[🔵🟢]\s*", f"{emoji} ", current_name)
        if not new_name.startswith(emoji):
            new_name = f"{emoji} {current_name}"

        subprocess.run(["tmux", "rename-window", new_name], check=True)
    except Exception:
        pass  # tmux環境外やエラーは無視


if __name__ == "__main__":
    main()
