#!/usr/bin/env bash
set -euo pipefail

eval "$(mise activate bash)"

target_pane="${HERDR_ACTIVE_PANE_ID:?HERDR_ACTIVE_PANE_ID is not set}"
base_dir="${HERDR_ACTIVE_PANE_CWD:-$PWD}"

selected=$(cd "$base_dir" && fd --type f --hidden --follow --exclude .git \
  | fzf -m --prompt="file> " --preview="bat --color=always --style=numbers --theme=ansi {}")
[ -z "$selected" ] && exit 0

text=$(printf '%s\n' "$selected" | while IFS= read -r f; do printf '%q ' "$f"; done)
herdr pane send-text "$target_pane" "${text% }"
