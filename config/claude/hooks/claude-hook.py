#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from enum import Enum
from pathlib import Path


class HookStatus(Enum):
    COMPLETED = "\uef0a "
    NOTIFICATION = "\udb83\udd59 "
    ONGOING = "\udb85\udc7d "

    @classmethod
    def get_emoji_pattern(cls) -> str:
        return "".join(status.value for status in cls)


class SoundType(Enum):
    STOP = "stop"
    NOTIFICATION = "notification"


def main():
    input_data = json.load(sys.stdin)
    hook_event = input_data.get("hook_event_name")

    with open(f"{os.environ['HOME']}/claude-hook.json", "a") as f:
        f.write(json.dumps(input_data))

    handlers = {
        "Notification": handle_notification_hook,
        "PostToolUse": handle_post_tool_use_hook,
        "Stop": handle_stop_hook,
        "UserPromptSubmit": handle_user_prompt_submit_hook,
    }

    handler = handlers.get(hook_event)

    if handler:
        handler(input_data)


def handle_notification_hook(input_data: dict):
    if input_data.get("notification_type") == "permission_prompt":
        update_tmux_window_name(HookStatus.NOTIFICATION)
        play_sound(SoundType.NOTIFICATION)


def handle_post_tool_use_hook(_: dict):
    update_tmux_window_name(HookStatus.ONGOING)


def handle_user_prompt_submit_hook(_: dict):
    update_tmux_window_name(HookStatus.ONGOING)


def handle_stop_hook(_: dict):
    update_tmux_window_name(HookStatus.COMPLETED)
    play_sound(SoundType.STOP)


def play_sound(sound_type: SoundType):
    try:
        subprocess.run(
            [
                "paplay",
                str(Path.home() / ".dotfiles" / "claude" / f"{sound_type.value}.wav"),
            ],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


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
