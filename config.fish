set -l OS (uname -s)

if test $OS = Darwin
  set -x IP (ifconfig en0 | grep -e "inet\s" | awk '$1=="inet" {print $2}')
end

if test -z $SSH_AGENT_PID
  eval (ssh-agent -c) > /dev/null
  ssh-add $HOME/.ssh/id_rsa > /dev/null 2>&1
end

begin # fisher
  if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
  end
end

begin # docker
  set image_name "devenv"
  set container_name "miya10kei-devenv"
  function startdev
    set opts "\
              --cap-add=ALL \
              --name $container_name \
              -v $HOME/.dotfiles:/root/.dotfiles \
              -v $HOME/.gradle:/root/.gradle \
              -v $HOME/.idea:/root/.IntelliJIdea2019.3 \
              -v $HOME/.java:/root/.java \
              -v $HOME/.local/share/JetBrains:/root/.local/share/JetBrains \
              -v $HOME/.local/share/fish/fish_history:/root/.local/share/fish/fish_history \
              -v $HOME/.m2:/root/.m2 \
              -v $HOME/Documents:/root/Documents \
              -v $HOME/Downloads:/root/Downloads \
              -v $HOME/dev:/root/dev \
              -v $HOME/.ssh:/tmp/.ssh:ro \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -e DISPLAY=$IP:0 \
              -v /tmp/.X11-unix/:/tmp/.X11-unix \
              $ARGS"
    set cmd "docker run -dit $opts $image_name"
    echo $cmd | sed "s/ \{2,\}/ /g"
    eval $cmd
  end
  alias stopdev "docker stop $container_name; docker rm $container_name"
  alias attachdev "docker exec -it $container_name /usr/bin/fish"
  alias dk "docker"
  alias rmnoneimg "docker rmi (docker images -f 'dangling=true' -q)"
end

begin # anyenv
  if test -e $HOME/.anyenv
    status --is-interactive; and source (anyenv init -|psub)
  end
end

begin # golang
  if type -q go
    set -x GOPATH "$HOME/go"
    set -U fish_user_paths "$GOPATH/bin" $fish_user_paths
  end
end

begin # GraalVM
  switch $OS
    case Darwin
      set -x GRAAL_HOME "/Library/Java/JavaVirtualMachines/graalvm-ce-java11-20.0.0/Contents/Home"
    case *
  end
end

begin # alias
  alias rm "rm -i"
  alias mv "mv -i"
  alias rr "rm -ri"
  alias rrf "rm -rf"

  alias u "cd ../"
  alias uu "cd ../../"
  alias uuu "cd ../../../"
  alias uuuu "cd ../../../../"
  alias cdr "cd -"
  if ls --color > /dev/null 2>&1
    alias ls "ls --color -hF"
    alias lsa "ls --color -ahF"
    alias ll "ls --color -hlF"
    alias lla "ls --color -ahlF"
  else
    alias ls "ls -FG"
    alias lsa "ls -a"
    alias ll "ls -l"
    alias lla "ll -a"
  end
  alias q "exit"
  alias fishconf "vim ~/.config/fish/config.fish"
  alias fishload "source ~/.config/fish/config.fish"
end


begin # neovim
  if type -q nvim
    set -x NVIM_HOME "$HOME/.config/nvim"
    alias vim "nvim"
  end
end

begin # util
  function decompress
    if test -f $argv[1]
      switch $argv[1]
        case "*.tar.gz"
          tar -zxvf $argv[1]
        case "*.tar.bz2"
          tar -jxvf $argv[1]
        case "*.tar.xz"
          tar -Jxvf $argv[1]
        case "*.tar"
          tar -xvf $argv[1]
        case "*.zip"
          unzip $argv[1]
        case "*"
          echo "😰 I don't know how to decompress $argv[1] ..."
      end
    else
      echo "🙅 $argv[1] is not a compressed file"
    end
  end
end


begin # key binding
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end
