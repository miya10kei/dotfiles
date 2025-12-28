#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from enum import Enum
from pathlib import Path


class HookStatus(Enum):
    COMPLETED = " \uef0a "
    NOTIFICATION = " \udb83\udd59 "
    ONGOING = " \udb85\udc7d "

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
        update_tmux_pane_title(HookStatus.NOTIFICATION)
        play_sound(SoundType.NOTIFICATION)


def handle_post_tool_use_hook(_: dict):
    # update_tmux_pane_title(HookStatus.ONGOING)
    pass


def handle_user_prompt_submit_hook(_: dict):
    # update_tmux_pane_title(HookStatus.ONGOING)
    pass


def handle_stop_hook(_: dict):
    # update_tmux_pane_title(HookStatus.COMPLETED)
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


def update_tmux_pane_title(status: HookStatus):
    """指定されたステータスでtmuxペインタイトルを更新"""
    try:
        pane_id = os.environ.get("TMUX_PANE")
        if not pane_id:
            return  # tmux環境外では何もしない

        # 現在のペインタイトルを取得
        result = subprocess.run(
            ["tmux", "display-message", "-p", "-t", pane_id, "#{pane_title}"],
            capture_output=True,
            text=True,
            check=True,
        )
        current_title = result.stdout.strip()

        emoji = status.value
        # 既存の絵文字を置き換え（または追加）- 末尾に付与
        emoji_pattern = HookStatus.get_emoji_pattern()
        new_title = re.sub(rf"[{emoji_pattern}]*$", f"{emoji}", current_title)
        if not new_title.endswith(emoji):
            new_title = f"{current_title}{emoji}"

        # ペインタイトルを更新
        subprocess.run(
            ["tmux", "select-pane", "-t", pane_id, "-T", new_title], check=True
        )
    except Exception:
        pass  # tmux環境外やエラーは無視


if __name__ == "__main__":
    main()
