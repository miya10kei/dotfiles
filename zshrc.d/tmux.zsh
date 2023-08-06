function tmux_popup() {
  local height='80%'
  local width='95%'
  local session=$(tmux display-message -p -F "#{session_name}")
  if [[ $session =~ 'popup' ]]; then
    tmux detach-client
  else
    tmux display-popup -d '#{pane_current_path}' -w$width -h$height -E "tmux attach -t popup || tmux new -s popup"
  fi
}
