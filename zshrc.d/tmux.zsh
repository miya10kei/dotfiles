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
