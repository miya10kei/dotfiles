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

function tmux_dev_layout() {
  tmux split-window -v -l "45%" -c "#{pane_current_path}"

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
  tmux send-keys -t 1 "nvim" Enter
  tmux send-keys -t 3 "claude" Enter
  tmux send-keys -t 4 "claude" Enter
  tmux send-keys -t 5 "claude" Enter
}
