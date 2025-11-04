#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from enum import Enum
from pathlib import Path


class HookStatus(Enum):
    """Hook処理の状態を表す絵文字"""

    DOING = "🟡"  # 処理中
    COMPLETED = "🟢"  # 完了

    @classmethod
    def get_emoji_pattern(cls) -> str:
        """全てのステータスの絵文字を正規表現パターンとして返す"""
        return "".join(status.value for status in cls)


def main():
    # stdinからJSONデータを読み取る
    input_data = json.load(sys.stdin)
    hook_event = input_data.get("hook_event_name")

    # hook_event毎のハンドラマッピング
    handlers = {
        "UserPromptSubmit": handle_user_prompt_submit_hook,
        "Stop": handle_stop_hook,
    }

    # 対応するハンドラを実行
    handler = handlers.get(hook_event)
    if handler:
        handler(input_data)


def handle_user_prompt_submit_hook(input_data):
    """UserPromptSubmit Hook時の処理"""
    update_tmux_window_name(HookStatus.DOING)


def handle_stop_hook(input_data):
    """Stop Hook時の処理"""
    update_tmux_window_name(HookStatus.COMPLETED)
    calculate_processing_time_and_play_sound(input_data)


def calculate_processing_time_and_play_sound(input_data):
    """処理時間を計算し、30秒超過時にサウンドを再生"""
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
                    content = entry.get("message", {}).get("content", "")
                    # contentが文字列の場合のみ（ツール実行結果は配列）
                    if isinstance(content, str):
                        last_user_timestamp = entry.get("timestamp")

                # 最後のassistantメッセージのタイムスタンプ（常に更新）
                if entry.get("type") == "assistant":
                    last_assistant_timestamp = entry.get("timestamp")

        # 処理時間を計算
        if last_user_timestamp and last_assistant_timestamp:
            start_time = datetime.fromisoformat(last_user_timestamp.replace("Z", "+00:00"))
            end_time = datetime.fromisoformat(last_assistant_timestamp.replace("Z", "+00:00"))
            elapsed_seconds = (end_time - start_time).total_seconds()

            # 30秒を超えていたら音声再生
            if elapsed_seconds > 30:
                subprocess.run(
                    ["paplay", str(Path.home() / ".dotfiles" / "claude" / "work_done.wav")],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
    except Exception:
        pass  # エラーは無視


def update_tmux_window_name(status: HookStatus):
    """指定されたステータスでtmuxウィンドウ名を更新"""
    try:
        # $TMUX_PANE環境変数から実行元のペインIDを取得
        pane_id = os.environ.get("TMUX_PANE")
        if not pane_id:
            return  # tmux環境外では何もしない

        # ペインが属するウィンドウIDを取得
        result = subprocess.run(
            ["tmux", "display-message", "-p", "-t", pane_id, "#I"],
            capture_output=True,
            text=True,
            check=True,
        )
        window_id = result.stdout.strip()

        # 特定のウィンドウの現在の名前を取得
        result = subprocess.run(
            ["tmux", "display-message", "-p", "-t", window_id, "#W"],
            capture_output=True,
            text=True,
            check=True,
        )
        current_name = result.stdout.strip()

        emoji = status.value
        # 既存の絵文字を置き換え（または追加）
        emoji_pattern = HookStatus.get_emoji_pattern()
        new_name = re.sub(rf"^[{emoji_pattern}]*", f"{emoji}", current_name)
        if not new_name.startswith(emoji):
            new_name = f"{emoji}{current_name}"

        # 特定のウィンドウに対して名前を更新
        subprocess.run(["tmux", "rename-window", "-t", window_id, new_name], check=True)
    except Exception:
        pass  # tmux環境外やエラーは無視


if __name__ == "__main__":
    main()
