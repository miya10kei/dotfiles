# gruvbox-dark-hard
# FZF_COLOR='bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598'
# kanagawa
# FZF_COLOR='fg:#dcd7ba,fg+:#c8c093,bg:#1f1f28,bg+:#2d4f67,hl:#7e9cd8,hl+:#7fb4ca,info:#54546d,marker:#ff9e3b,prompt:#938aa9,spinner:#957fb8,pointer:#ffa066,header:#7aa89f,gutter:#1f1f28,border:#54546d,label:#727169,query:#dcd7ba'

FZF_COLOR="bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8,fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC,marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8,selected-bg:#45475A,border:#6C7086,label:#CDD6F4"

export FZF_DEFAULT_OPTS="--color=$FZF_COLOR --layout=reverse --info=inline --preview-window='down,50%,wrap'"
export FZF_TMUX=1
#export FZF_TMUX_OPTS='-p -h "80%" -w "95%"'
export FZF_TMUX_OPTS='-p 90%'
export FZF_DEFAULT_OPTS="--color=$FZF_COLOR --layout=reverse --info=inline --preview-window='down,50%,wrap'"

FZF_CTRL_T_PREVIEW="bat --color=always --style=numbers --theme=ansi {}"
export FZF_CTRL_T_OPTS="--preview=\"$FZF_CTRL_T_PREVIEW\""

FZF_CTRL_R_PREVIEW="echo {} | awk '{ print substr(\$0, index(\$0,\$2)) }' | bat --color=always --language=sh --style=plain --theme=ansi"
export FZF_CTRL_R_OPTS="--preview=\"$FZF_CTRL_R_PREVIEW\""

FZF_MISE_DIR="$HOME/.local/share/mise/installs"
[[ -f "$FZF_MISE_DIR/http-fzf-completion/latest/completion.zsh" ]] && source "$FZF_MISE_DIR/http-fzf-completion/latest/completion.zsh"
[[ -f "$FZF_MISE_DIR/http-fzf-key-bindings/latest/key-bindings.zsh" ]] && source "$FZF_MISE_DIR/http-fzf-key-bindings/latest/key-bindings.zsh"
bindkey "ç" fzf-cd-widget
