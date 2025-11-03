function launch_dev_env() {
    name="dev-env"
    os=$(uname)
    uname=$(id -un)

    if [ -n "$(docker container ls -q -f name=$name)" ]; then
        docker rm --force dev-env
    fi

    opts=(
        "--detach"
        "--env DISPLAY=host.docker.internal:0"
        "--interactive"
        "--mount type=bind,source=${HOME}/.dotfiles,target=/home/${uname}/.dotfiles"
        "--mount type=bind,source=${HOME}/.dotfiles/.zshrc,target=/home/${uname}/.zshrc"
        "--mount type=bind,source=${HOME}/.ssh,target=/home/${uname}/.ssh"
        "--mount type=bind,source=${HOME}/dev,target=/home/${uname}/dev"
        "--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock"
        "--name=dev-env"
        "--net=host"
        "--restart=always"
        "--tty"
    )

    case "$os" in
        Darwin)
            opts+=(
                "--mount type=bind,source=${HOME}/.Xauthority,target=/home/${uname}/.Xauthority"
                "--mount type=bind,source=${HOME}/.config/pulse,target=/home/${uname}/.config/pulse"
                "--mount type=bind,source=${HOME}/Documents,target=/home/${uname}/Documents"
                "--mount type=bind,source=${HOME}/Google\ Drive,target=/home/${uname}/Google\ Drive"
                "--mount type=bind,source=/private/tmp/.X11-unix,target=/tmp/.X11-unix"
            )
            ;;
          Linux)
            opts+=(
                "--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix"
            )
            ;;
    esac
    cmd="docker run $opts miya10kei/devenv:latest"
    echo $cmd
    eval $cmd
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
