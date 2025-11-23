if builtin command -v docker > /dev/null 2>&1; then

  function exec_docker_command() {
    cmd=$1
    echo -e "\e[32m\$$cmd\e[m"
    print -s $cmd
    eval $cmd
  }

  function dk-images-rm() {
    local image_ids=$(docker images --filter "dangling=false" --format "{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}" | column -t | sort | fzf -m | awk '{print $2}' | tr '\n' ' ')

    if [ -z "$image_ids" ]; then
      return
    fi

    exec_docker_command "docker image rm -f $image_ids"
  }

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
fi
