function main() {
    PROMPT='%~$ '

    if [[ -e /bin/zsh ]]; then
        export SHELL='/bin/zsh'
    else
        export SHELL='/usr/bin/zsh'
    fi
    export GPG_TTY=$(tty)
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

    add_path "$HOME/.bun/bin"
    add_path "$HOME/.cargo/bin"
    add_path "$HOME/.deno/bin"
    add_path "$HOME/.docker/bin"
    add_path "$HOME/.ghcup/bin"
    add_path "$HOME/.local/bin"
    add_path "$HOME/.local/share/nvim/mason/bin"
    add_path "$HOME/.pyenv/bin"
    add_path "$HOME/.rye/shims"
    add_path "$HOME/Library/Python/3.11/bin"
    add_path "$HOME/go/bin"
    add_path "/usr/local/go/bin"
    add_path "/usr/local/nodejs/bin"


    # ------------
    # --- tmux ---
    # ------------
    if builtin command -v tmux > /dev/null 2>&1; then
        if [[ ! -e $HOME/.tmux/plugins/tpm ]]; then
            git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/
        fi
    fi

    # -----------------
    # --- in docker ---
    # -----------------
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
    setopt hist_ignore_space
    setopt hist_reduce_blanks
    setopt hist_verify
    setopt inc_append_history
    setopt share_history

    # --------------
    # --- plugin ---
    # --------------

    if builtin command -v sheldon > /dev/null 2>&1; then
        eval "$(sheldon source)"
    fi

    if [[ -e $HOME/.dotfiles/zshrc.d ]]; then
        source $HOME/.dotfiles/zshrc.d/docker.zsh
        source $HOME/.dotfiles/zshrc.d/aliases.zsh

        if builtin command -v aws > /dev/null 2>&1; then
          source $HOME/.dotfiles/zshrc.d/aws.zsh
        fi

        if builtin command -v fzf > /dev/null 2>&1; then
            source $HOME/.dotfiles/zshrc.d/fzf.zsh
        fi

        if builtin command -v tmux > /dev/null 2>&1; then
            source $HOME/.dotfiles/zshrc.d/tmux.zsh
        fi
    fi

    if [[ -e $HOME/.bun/_bun ]]; then
        source "$HOME/.bun/_bun"
    fi

    if [[ -e $HOME/.pyenv ]]; then
        eval "$(pyenv init -)"
    fi

    if [[ -e $HOME/.rye/env ]]; then
        source "$HOME/.rye/env"
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

    FPATH="$HOME/.local/share/zsh-completion/completions:$FPATH"
    autoload bashcompinit && bashcompinit
    autoload -Uz compinit && compinit
    complete -C "$HOME/.local/bin/aws_completer" aws
}

if [ "$ZPROFILE_ENABLED" = true ]; then
    zmodload zsh/zprof && zprof
    main
    zprof
else
    main
fi
