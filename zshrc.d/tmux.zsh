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

  tmux select-pane -t 1 -T " Neovim"
  tmux select-pane -t 2 -T " Terminal"
  tmux select-pane -t 3 -T "󱜚 Claude (Code1)"
  tmux select-pane -t 4 -T "󱜚 Claude (Code2)"
  tmux select-pane -t 5 -T " Claude (Q&A)"

  tmux select-pane -t 1

  sleep 1s
  tmux send-keys -t 1 "nvim" Enter
  tmux send-keys -t 3 "claude" Enter
  tmux send-keys -t 4 "claude" Enter
  tmux send-keys -t 5 "claude" Enter
}

function tmux_two_column() {
  [[ -n "$TMUX" ]] || return
  setopt local_options extended_glob

  # キャプチャ範囲。バッファ全体が対象。直近のみにしたい場合は "-" を "-3000" 等に変更する
  local capture_start="-"
  local width="95%"
  local height="90%"

  # 折り返し幅: ポップアップ幅から枠線(2)とカラム間の区切り(3)を差し引いて2分割する
  local -i client_width=$(tmux display-message -p '#{client_width}')
  local -i popup_width=$(( client_width * ${width%\%} / 100 ))
  local -i col_width=$(( (popup_width - 5) / 2 ))
  (( col_width > 0 )) || return

  # 色付き(-e)でキャプチャする。折り返し行は -J で論理行に結合する
  local -a lines
  lines=( "${(@f)$(tmux capture-pane -p -e -J -S "$capture_start")}" )

  # 各行を表示幅 col_width で折り返す（全角文字・ANSIエスケープの表示幅を考慮）
  local -a wrapped
  local line stripped
  for line in "${lines[@]}"; do
    stripped=${line//$'\e['[0-9;:?]#[a-zA-Z]/}
    if (( ${(m)#stripped} <= col_width )); then
      wrapped+=("$line")
    else
      wrapped+=("${(@f)$(_wrap_display_width "$line" "$col_width")}")
    fi
  done

  local -i total=${#wrapped}
  (( total > 0 )) || return

  # バッファ全体を1回だけ折り返し、左列＝前半／右列＝後半の2段組にする。
  # 継ぎ目は「左列の最下行→右列の最上行」の1か所だけで、全行が抜けなく連結される。
  local -i half=$(( (total + 1) / 2 ))
  local tmpfile
  tmpfile=$(mktemp -t tmux-2col.XXXXXX) || return
  local -i k ri pad
  local left empty="" reset=$'\e[0m'
  {
    for (( k = 1; k <= half; k++ )); do
      left=${wrapped[k]}
      # ANSIエスケープを除いた表示幅で左列を空白パディングする
      stripped=${left//$'\e['[0-9;:?]#[a-zA-Z]/}
      pad=$(( col_width - ${(m)#stripped} ))
      (( pad < 0 )) && pad=0
      ri=$(( half + k ))
      if (( ri <= total )); then
        print -r -- "${left}${reset}${(l[pad])empty} │ ${wrapped[ri]}${reset}"
      else
        print -r -- "${left}${reset}"
      fi
    done
  } > "$tmpfile"

  # 表示に使うビューア
  local viewer_name="less"
  local viewer="less -R +G"

  # 直近のプランが見えるよう末尾から開く。枠線のタイトルにビューア名を表示する
  tmux display-popup -w$width -h$height -T " viewer: ${viewer_name} " \
    -E "${viewer} ${(q)tmpfile}; rm -f ${(q)tmpfile}"
}

function _wrap_display_width() {
  local str=$1
  local -i max=$2
  local cur="" sgr="" ch esc
  local -i curw=0 cw idx=1 len=${#str}
  while (( idx <= len )); do
    ch=${str[idx]}
    if [[ $ch == $'\e' ]]; then
      # CSIエスケープシーケンスを丸ごと取り込む（表示幅は0として扱う）
      esc=$'\e'
      (( idx++ ))
      if [[ ${str[idx]} == '[' ]]; then
        esc+='['
        (( idx++ ))
        while (( idx <= len )) && [[ ${str[idx]} != [a-zA-Z] ]]; do
          esc+=${str[idx]}
          (( idx++ ))
        done
        if (( idx <= len )); then
          esc+=${str[idx]}
          (( idx++ ))
        fi
      fi
      cur+=$esc
      # 折り返し後の継続行へ引き継ぐSGR状態を更新する
      if [[ $esc == $'\e['*m ]]; then
        if [[ $esc == $'\e[0m' || $esc == $'\e[m' ]]; then
          sgr=""
        else
          sgr+=$esc
        fi
      fi
      continue
    fi
    cw=${(m)#ch}
    if (( curw > 0 && curw + cw > max )); then
      print -r -- "$cur"
      cur="${sgr}${ch}"
      curw=$cw
    else
      cur+=$ch
      (( curw += cw ))
    fi
    (( idx++ ))
  done
  print -r -- "$cur"
}
