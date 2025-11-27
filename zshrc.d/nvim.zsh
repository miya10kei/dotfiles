# Neovim Remote (nvr) configuration
# Neovim内のターミナルでファイルを開くと、親Neovimで開くようにする

if [[ -n "$NVIM" ]]; then
    # Neovim内のターミナルで実行されている場合
    export EDITOR="nvr --remote-wait"
    export VISUAL="nvr --remote-wait"
    alias nvim="nvr --remote"
    alias vim="nvr --remote"
    alias v="nvr --remote"
else
    # 通常のシェルで実行されている場合
    export EDITOR="nvim"
    export VISUAL="nvim"
fi
