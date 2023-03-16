function tmux_with_tpm() {
    if type tmux > /dev/null 2>&1; then
        if [ ! -e $HOME/.tmux/plugins/tpm ]; then
            git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        fi
    	tmux new-session -A -s main
    fi
}
if [ -z $TMUX ]; then tmux_with_tpm; fi

PROMPT='%~$ '
export SHELL='/usr/bin/zsh'
export TERM='xterm-256color'
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.ghcup/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="/usr/local/nodejs/bin:$PATH"

alias g='git'
alias ll='exa -al'
alias ls='exa -a'
alias q='exit'
alias rm='rm -i'
alias rr='rm -ir'
alias rrf='rm -fr'
alias u='cd ../'
alias uu='cd ../../'
alias uuu='cd ../../../'
alias uuuu='cd ../../../../'
alias v='nvim'
alias lde='launch_dev_env'
alias ade='attach_dev_env'
alias tde='terminate_dev_env'
alias db="docker build -t miya10kei/devenv:latest --progress=plain $HOME/.dotfiles"

function launch_dev_env() {
    docker run \
	--detach \
	--name=dev-env \
	--privileged \
        --hostname=dev-env \
        --mount type=bind,source=$HOME/.dotfiles,target=/root/.dotfiles \
        --mount type=bind,source=$HOME/.dotfiles/.tmux.conf,target=/root/.tmux.conf \
        --mount type=bind,source=$HOME/.dotfiles/.zshrc,target=/root/.zshrc \
        --mount type=bind,source=$HOME/.dotfiles/nvim,target=/root/.config/nvim \
        --mount type=bind,source=$HOME/dev,target=/root/dev \
        miya10kei/devenv:latest \
	/sbin/init
}

function attach_dev_env() {
    docker exec \
	--tty \
        --interactive \
	dev-env \
	/usr/bin/zsh
}

function terminate_dev_env() {
    docker stop dev-env
}
