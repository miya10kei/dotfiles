# gruvbox-dark-hard
FZF_COLOR='bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598'
export FZF_TMUX=1
#export FZF_TMUX_OPTS='-p -h "80%" -w "95%"'
export FZF_TMUX_OPTS='-p 90%'
export FZF_DEFAULT_OPTS="--color=$FZF_COLOR --layout=reverse --info=inline --preview-window='down,50%,wrap'"

FZF_CTRL_T_PREVIEW="bat --color=always --style=numbers --theme=gruvbox-dark {}"
export FZF_CTRL_T_OPTS="--preview=\"$FZF_CTRL_T_PREVIEW\""

FZF_CTRL_R_PREVIEW="echo {} | awk '{ print substr(\$0, index(\$0,\$2)) }' | bat --color=always --language=sh --style=plain --theme=gruvbox-dark"
export FZF_CTRL_R_OPTS="--preview=\"$FZF_CTRL_R_PREVIEW\""

if [[ -e $HOME/.local/bin/fzf-key-bindings.zsh ]]; then
    source $HOME/.local/bin/fzf-key-bindings.zsh
fi
bindkey "ç" fzf-cd-widget
