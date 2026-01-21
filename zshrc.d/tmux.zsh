function _update_tmux_window_name() {
  if [[ -n "$TMUX" ]]; then
    local pane_index=$(tmux display-message -p '#{pane_index}')
    if [[ "$pane_index" == "1" ]]; then
      tmux rename-window "$(basename "$PWD")"
    fi
  fi
}
add-zsh-hook chpwd _update_tmux_window_name

function tmux_popup() {
  local height="90%"
  local width="95%"
  local session=$(tmux display-message -p -F "#{session_name}")
  if [[ $session =~ "popup" ]]; then
    tmux detach-client
  else
    tmux display-popup -d "#{pane_current_path}" -w$width -h$height -E "tmux attach -t popup || tmux new -s popup"
  fi
}

# ----------------------------------------------
# Neovim server functions (for AI agent integration)
# ----------------------------------------------

# Calculate socket path from directory
function nvim_socket_path() {
  local dir="${1:-$PWD}"
  dir="$(cd "$dir" 2>/dev/null && pwd -P)"
  local hash=$(printf '%s' "$dir" | shasum -a 256 2>/dev/null | cut -c1-12 || printf '%s' "$dir" | cksum | awk '{print $1}')
  echo "/tmp/nvim-${hash}.sock"
}

# Start nvim with socket (for remote control via nvr)
function nvim_server() {
  local sock=$(nvim_socket_path)

  # Clean up stale socket
  if [[ -S "$sock" ]]; then
    if ! nvr --serverlist 2>/dev/null | grep -q "$sock"; then
      rm -f "$sock"
    fi
  fi

  # Start nvim with socket
  nvim --listen "$sock" "$@"
}

# Open file in existing nvim instance via nvr
# Supports: path, path:line, path:line:col
function open_in_nvim() {
  local input="$1"
  [[ -z "$input" ]] && return 1

  # Parse path:line:col
  local filepath="${input%%:*}"
  local line="${${input#*:}%%:*}"

  # Resolve relative path
  [[ "$filepath" != /* ]] && filepath="${TMUX_PANE_PATH:-$PWD}/$filepath"

  # Find nvim server
  local server=$(nvr --serverlist 2>/dev/null | head -1)
  [[ -z "$server" ]] && { echo "No nvim server" >&2; return 1; }

  # Open in nvim
  if [[ "$line" =~ ^[0-9]+$ ]]; then
    nvr --servername "$server" --remote "+$line" "$filepath"
  else
    nvr --servername "$server" --remote "$filepath"
  fi
}

# Pick path from tmux pane output using fzf
function tmux_pick_path() {
  # Capture pane content (last 2000 lines)
  local content=$(tmux capture-pane -p -S -2000)

  # Extract path-like strings using ripgrep
  local paths=$(echo "$content" | rg -o '[A-Za-z0-9_./-]+\.[a-zA-Z0-9]+(?::\d+(?::\d+)?)?' | sort -u | tac)

  if [[ -z "$paths" ]]; then
    echo "No paths found in pane output"
    return 1
  fi

  # Select with fzf
  local selected=$(echo "$paths" | fzf --reverse --height=100% --prompt="Open in nvim> ")

  if [[ -n "$selected" ]]; then
    TMUX_PANE_PATH="$(tmux display-message -p '#{pane_current_path}')" open_in_nvim "$selected"
  fi
}

# ----------------------------------------------
# Development layout
# ----------------------------------------------

function tmux_dev_layout() {
  tmux split-window -v -l "35%" -c "#{pane_current_path}"

  tmux select-pane -t 1
  tmux split-window -h -l "30%" -c "#{pane_current_path}"

  tmux select-pane -t 3
  tmux split-window -h -l "66%" -c "#{pane_current_path}"

  tmux select-pane -t 4
  tmux split-window -h -l "50%" -c "#{pane_current_path}"

  tmux select-pane -t 1 -T " Neovim"
  tmux select-pane -t 2 -T " Terminal"
  tmux select-pane -t 3 -T "󱜚 Claude (Code1)"
  tmux select-pane -t 4 -T "󱜚 Claude (Code2)"
  tmux select-pane -t 5 -T " Claude (Q&A)"

  tmux select-pane -t 1

  sleep 1s
  tmux send-keys -t 1 "nvim_server" Enter
  tmux send-keys -t 3 "claude" Enter
  tmux send-keys -t 4 "claude" Enter
  tmux send-keys -t 5 "claude" Enter
}
