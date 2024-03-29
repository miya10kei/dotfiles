function launch_dev_env() {
    docker rm --force dev-env
    docker run \
        --add-host host.docker.internal:host-gateway \
        --detach \
        --env DISPLAY=host.rancher-desktop.internal:0 \
        --hostname=dev-env \
        --interactive \
        --mount type=bind,source=$HOME/.Xauthority,target=/root/.Xauthority \
        --mount type=bind,source=$HOME/.dotfiles,target=/root/.dotfiles \
        --mount type=bind,source=$HOME/.dotfiles/.zshrc,target=/root/.zshrc \
        --mount type=bind,source=$HOME/.ssh,target=/root/.ssh \
        --mount type=bind,source=$HOME/Documents,target=/root/Documents \
        --mount type=bind,source=$HOME/dev,target=/root/dev \
        --mount type=bind,source=/private/tmp/.X11-unix,target=/tmp/.X11-unix \
        --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
        --name=dev-env \
        --publish=3000:3000\
        --publish=35432:35432 \
        --publish=4200:4200\
        --publish=4300:4300\
        --publish=8090:8090 \
        --publish=8100:8100 \
        --restart=always \
        --tty \
        miya10kei/devenv:latest
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


alias lde='launch_dev_env'
alias ade='attach_dev_env'
alias tde='terminate_dev_env'
alias dki="docker inspect \$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}' | column -t -s $'\t' | fzf | awk '{print($1)}')"
