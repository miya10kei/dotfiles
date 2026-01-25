function main() {
    PROMPT='%~$ '

    if [[ -e /bin/zsh ]]; then
        export SHELL='/bin/zsh'
    else
        export SHELL='/usr/bin/zsh'
    fi
    export GPG_TTY=$(tty)

    # ------------
    # --- path ---
    # ------------
    function add_path() {
        new_path=$1
        if [[ ! $PATH =~ $new_path ]]; then
            if [[ -e $new_path ]]; then
                export PATH="$new_path:$PATH"
            fi
        fi
    }

    add_path "$HOME/.bun/bin"
    add_path "$HOME/.cargo/bin"
    add_path "$HOME/.docker/bin"
    add_path "$HOME/.ghcup/bin"
    add_path "$HOME/.local/bin"
    add_path "$HOME/.local/share/nvim/mason/bin"
    add_path "$HOME/.rd/bin"
    add_path "$HOME/.tfenv/bin"
    add_path "$HOME/Library/Python/3.11/bin"
    add_path "/usr/local/nodejs/bin"

    # -----------------
    # --- Claude Code -
    # -----------------
    if builtin command -v claude > /dev/null 2>&1; then
        export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
    fi

    # -------------
    # --- Node.js -
    # -------------
    if [[ -e /opt/homebrew/opt/node@22 ]]; then
        export LDFLAGS="-L/opt/homebrew/opt/node@22/lib"
        export CPPFLAGS="-I/opt/homebrew/opt/node@22/include"
        add_path "/opt/homebrew/opt/node@22/bin"
    fi

    # ----------------
    # --- Safe Chain -
    # ----------------
    if [[ -e $HOME/.safe-chain/scripts/init-posix.sh ]]; then
        source $HOME/.safe-chain/scripts/init-posix.sh
    fi

    # ------------------
    # --- pulseaudio ---
    # ------------------
    if builtin command -v pulseaudio > /dev/null 2>&1; then
        if [[ ! -e /.dockerenv ]]; then
            pulseaudio --check > /dev/null 2>&1 || pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
        else
            export PULSE_SERVER=host.docker.internal
        fi
    fi

    # -----------------
    # --- in docker ---
    # -----------------
    if [[ -e /.dockerenv ]]; then
        if [[ $$ = 1 ]]; then
            if [[ -e $HOME/.dotfiles/Makefile ]]; then
                eval "$(mise activate zsh)"
                pushd $HOME/.dotfiles
                make --always-make --makefile $HOME/.dotfiles/Makefile setup4d
                popd
                # TODO
                sudo chmod 777 /var/run/docker.sock
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
    setopt interactivecomments
    setopt share_history

    # ---------------
    # --- source  ---
    # ---------------
    if [ -e $HOME/.dotfiles/secrets.sh ]; then
        source $HOME/.dotfiles/secrets.sh
    fi

    # --------------
    # --- plugin ---
    # --------------

    if builtin command -v mise > /dev/null 2>&1; then
        eval "$(mise activate zsh)"
    fi

    if builtin command -v sheldon > /dev/null 2>&1; then
        eval "$(sheldon source)"
    fi

    autoload -Uz add-zsh-hook

    if [[ -e $HOME/.dotfiles/zshrc.d ]]; then
        source $HOME/.dotfiles/zshrc.d/docker.zsh
        source $HOME/.dotfiles/zshrc.d/aliases.zsh
        source $HOME/.dotfiles/zshrc.d/gtr.zsh

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

    if [[ -e "$HOME/.local/src/google-cloud-sdk" ]]; then
        source $HOME/.local/src/google-cloud-sdk/path.zsh.inc
        source $HOME/.local/src/google-cloud-sdk/completion.zsh.inc
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

