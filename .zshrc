function main() {
    PROMPT='%~$ '

    if [[ -e /bin/zsh ]]; then
        export SHELL='/bin/zsh'
    else
        export SHELL='/usr/bin/zsh'
    fi
    export GPG_TTY=$(tty)
    export PAID_MCP_VAULT_BACKEND=pass
    export TAKUMI_GUARD_TOKEN=$(pass show takumi-guard/token 2>/dev/null || echo "")
    if [[ -n "$TAKUMI_GUARD_TOKEN" ]]; then
        export UV_DEFAULT_INDEX="https://token:${TAKUMI_GUARD_TOKEN}@pypi.flatt.tech/simple/"
        export PIP_INDEX_URL="https://token:${TAKUMI_GUARD_TOKEN}@pypi.flatt.tech/simple/"
    fi

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

    add_path "$HOME/.docker/bin"
    add_path "$HOME/.local/bin"
    add_path "$HOME/.rd/bin"

    # -----------------
    # --- Claude Code -
    # -----------------
    if builtin command -v claude > /dev/null 2>&1; then
        export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
    fi

    # -------------
    # --- herdr ---
    # -------------
    # ~/.config/herdrはbind mount上のdotfilesを指すため、socketはコンテナローカルに置く
    export HERDR_SOCKET_PATH="/tmp/herdr/herdr.sock"

    # -------------
    # --- Node.js -
    # -------------
    export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"

    if builtin command -v taplo > /dev/null 2>&1; then
        export TAPLO_CONFIG="$HOME/.config/taplo/taplo.toml"
    fi

    # ------------------
    # --- pulseaudio ---
    # ------------------
    # コンテナには paplay（pulseaudio-utils）だけを入れ、ホストの PulseAudio サーバーで鳴らす
    if [[ -e /.dockerenv ]]; then
        if builtin command -v paplay > /dev/null 2>&1; then
            export PULSE_SERVER=host.docker.internal
        fi
    elif builtin command -v pulseaudio > /dev/null 2>&1; then
        pulseaudio --check > /dev/null 2>&1 || pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
    fi

    # -----------------
    # --- in docker ---
    # -----------------
    if [[ -e /.dockerenv ]]; then
        if [[ $$ = 1 ]]; then
            if [[ -e $HOME/.dotfiles/mise.toml ]]; then
                # mise.tomlが未trustだと、activateのフックやdot applyが警告を出すため先にtrustする
                mise trust --quiet $HOME/.dotfiles/mise.toml
                eval "$(mise activate zsh)"
                # 配置はmise.tomlの[dotfiles]と前後のフックで定義している
                mise --cd $HOME/.dotfiles dotfiles apply --yes
                # TODO
                sudo chmod 777 /var/run/docker.sock
            fi
        fi
    fi


    # ---------------
    # --- history ---
    # ---------------
    export HISTFILE=${HOME}/.zsh_history
    # Ctrl-R などで検索できるのはメモリ上の HISTSIZE 件だけなので、保存件数と揃える
    export HISTSIZE=100000
    export SAVEHIST=100000
    # share_history は追記も行うため inc_append_history は併用しない（zshのドキュメントの指示）
    setopt extended_history
    setopt hist_ignore_all_dups
    setopt hist_ignore_space
    setopt hist_reduce_blanks
    setopt hist_verify
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
        export PATH="$HOME/.local/share/mise/shims:$PATH"
        eval "$(mise activate zsh)"
    fi

    # fzf-tab requires compinit to have already run before it is loaded via sheldon
    # 補完の初期化は、.zcompdump が無いか24時間以上古いときだけ再生成し、それ以外は確認を省いて読み込む
    autoload -Uz compinit
    local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    local stale_zcompdump=( "$zcompdump"(N.mh+24) )
    if [[ ! -s "$zcompdump" ]] || (( ${#stale_zcompdump} )); then
        compinit -d "$zcompdump"
    else
        compinit -C -d "$zcompdump"
    fi
    autoload bashcompinit && bashcompinit
    if builtin command -v aws_completer > /dev/null 2>&1; then
        complete -C aws_completer aws
    fi

    if builtin command -v mise > /dev/null 2>&1; then
        eval "$(mise completion zsh)"
    fi

    if builtin command -v sheldon > /dev/null 2>&1; then
        eval "$(sheldon source)"
    fi

    autoload -Uz add-zsh-hook

    if [[ -e $HOME/.dotfiles/zshrc.d ]]; then
        source $HOME/.dotfiles/zshrc.d/docker.zsh
        source $HOME/.dotfiles/zshrc.d/aliases.zsh

        if builtin command -v aws > /dev/null 2>&1; then
          source $HOME/.dotfiles/zshrc.d/aws.zsh
        fi

        if builtin command -v fzf > /dev/null 2>&1; then
            source $HOME/.dotfiles/zshrc.d/fzf.zsh
        fi

    fi

    if builtin command -v starship > /dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi

    if builtin command -v zoxide > /dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi

}

if [ "$ZPROFILE_ENABLED" = true ]; then
    zmodload zsh/zprof && zprof
    main
    zprof
else
    main
fi
