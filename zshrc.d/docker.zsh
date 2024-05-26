function launch_dev_env() {
    name="dev-env"
    os=$(uname)
    uname=$(id -un)

    if [ -n "$(docker container ls -q -f name=$name)" ]; then
        docker rm --force dev-env
    fi

    opts=(
        "--add-host host.docker.internal:host-gateway"
        "--detach"
        "--hostname=dev-env"
        "--interactive"
        "--mount type=bind,source=${HOME}/.dotfiles,target=/home/${uname}/.dotfiles"
        "--mount type=bind,source=${HOME}/.dotfiles/.zshrc,target=/home/${uname}/.zshrc"
        "--mount type=bind,source=${HOME}/.ssh,target=/home/${uname}/.ssh"
        "--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock"
        "--name=dev-env"
        "--restart=always"
        "--tty"
    )

    case "$os" in
        Darwin)
            opts+=(
                "--env DISPLAY=host.rancher-desktop.internal:0"
                "--mount type=bind,source=${HOME}/.Xauthority,target=/home/${uname}/.Xauthority"
                "--mount type=bind,source=${HOME}/Documents,target=/home/${uname}/Documents"
                "--mount type=bind,source=${HOME}/dev,target=/home/${uname}/dev"
                "--mount type=bind,source=/private/tmp/.X11-unix,target=/tmp/.X11-unix"
                "--publish=3000:3000"
                "--publish=35432:35432"
                "--publish=4200:4200"
                "--publish=4300:4300"
                "--publish=8090:8090"
                "--publish=8100:8100"
            )
            ;;
          Linux)
            opts+=(
                "--mount type=bind,source=${HOME}/dev,target=/home/${uname}/dev"
                "--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix"
                "--net=host"
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
