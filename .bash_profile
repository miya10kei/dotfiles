[ -e $HOME/.bashrc ] && source ~/.bashrc

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

echo ".bash_profile loaded"

export PATH="$HOME/.cargo/bin:$PATH"

if type tmux> /dev/null 2>&1; then
  tmux
fi

