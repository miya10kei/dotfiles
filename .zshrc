function main() {
    PROMPT='%~$ '

    export SHELL='/usr/bin/zsh'
    export TERM='xterm-256color'

    # ------------
    # --- path ---
    # ------------
    function add_path() {
        new_path=$1
        if [[ ! $PATH =~ $new_path ]]; then
            export PATH="$new_path:$PATH"
        fi
    }

    add_path "$HOME/.cargo/bin"
    add_path "$HOME/.deno/bin"
    add_path "$HOME/.docker/bin"
    add_path "$HOME/.ghcup/bin"
    add_path "$HOME/.local/bin"
    add_path "$HOME/.local/share/nvim/mason/bin"
    add_path "$HOME/Library/Python/3.11/bin"
    add_path "/usr/local/go/bin"
    add_path "/usr/local/nodejs/bin"


    # ---------------
    # --- utility ---
    # ---------------
    if type tmux > /dev/null 2>&1; then
        if [ ! -e $HOME/.tmux/plugins/tpm ]; then
            git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/
        fi
    fi

    if [[ -e /.dockerenv ]]; then
        if [[ $$ = 1 ]]; then
            if [[ -e $HOME/.dotfiles/Makefile ]]; then
                pushd $HOME/.dotfiles
                make --always-make --makefile $HOME/.dotfiles/Makefile setup4d
                popd
            fi
        else
            if [[ -z $TMUX ]]; then
                tmux new-session -A -s main
            fi
        fi
    fi


    # ---------------
    # --- history ---
    # ---------------
    export HISTFILE=${HOME}/.zsh_history
    export HISTSIZE=10000
    export SAVEHIST=100000
    setopt append_history
    setopt extended_history
    setopt hist_ignore_all_dups
    setopt hist_ignore_dups
    setopt hist_no_store
    setopt hist_reduce_blanks
    setopt hist_verify
    setopt inc_append_history
    setopt share_history

    if [[ -e $HOME/.nvm ]]; then
        export NVM_DIR=$HOME/.nvm
        . $NVM_DIR/nvm.sh
    fi


    if [[ -e $HOME/.dotfiles/zshrc.d ]]; then
        source $HOME/.dotfiles/zshrc.d/plugins.zsh
        source $HOME/.dotfiles/zshrc.d/docker.zsh
        source $HOME/.dotfiles/zshrc.d/aliases.zsh
    fi

    if builtin command -v starship > /dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi

    if builtin command -v zoxide > /dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi

    if builtin command -v xhost > /dev/null 2>&1; then
        xhost + localhost
    fi

    if builtin command -v fzf > /dev/null 2>&1; then
        # gruvbox-dark-hard
        FZF_COLOR='bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598'
        export FZF_DEFAULT_OPTS="--layout=reverse --height=50% --border --margin=1 --padding=1 --info=inline --color=$FZF_COLOR"
        FZF_PREVIEW_BAT_OPTION='--style=numbers --color=always --theme=TwoDark --line-range :500 {}'
        export FZF_CTRL_T_OPTS="--preview='batcat $FZF_PREVIEW_BAT_OPTION' --preview-window right:70%"

        function fzf-select-history() {
            BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
            CURSOR=$#BUFFER
            zle reset-prompt
        }
        zle -N fzf-select-history
        bindkey '^r' fzf-select-history
    fi

    FPATH="$HOME/.local/share/zsh-completion/completions:$FPATH"
    autoload -Uz compinit && compinit
}

if [ "$ZPROFILE_ENABLED" = true ]; then
    zmodload zsh/zprof && zprof
    main
    zprof
else
    main
fi
