set -l OS (uname -s)
set -g fish_emoji_width 2
set -x TERM screen-256color

if test $OS = Darwin
  set -x IP (ifconfig en0 | grep -e "inet\s" | awk '$1=="inet" {print $2}')
end

begin # SSH Agent
  if test -z $SSH_AGENT_PID
    eval (ssh-agent -c) > /dev/null
    ssh-add $HOME/.ssh/id_rsa > /dev/null 2>&1
  end
end

begin # X Window System
  if type -q xhost
    xhost + > /dev/null 2>&1
  end
end

begin # bobthefish
  set -g theme_color_scheme gruvbox
  set -g theme_show_exit_status yes
end

begin # docker
  if type -q docker
    set image_name "miya10kei/devenv"
    set container_name "miya10kei-devenv"
    set tag "latest"
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
                -p 8080:8080 \
                $ARGS"
      set cmd "docker run -dit $opts $image_name:$tag"
      echo $cmd | sed "s/ \{2,\}/ /g"
      eval $cmd
    end
    alias stopdev "docker stop $container_name; docker rm $container_name"
    alias attachdev "docker exec -it $container_name /usr/bin/fish"
    alias dk "docker"
    alias rmnoneimg "docker rmi (docker images -f 'dangling=true' -q)"
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
  if type -q ghq; and type -q peco
    alias ghq "echo -ne \"🙅 Use of this command is prohibited.\nPlease use 'pghq' or 'wghq' command.\n\""
    alias pghq "echo -ne \"[ghq]\n  root = ~/dev/private\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
    alias wghq "echo -ne \"[ghq]\n  root = ~/dev/work\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
    alias cdp 'pghq list | peco | read b; if test !!$b; cd (pghq root)/$b; end;'
    alias cdw 'wghq list | peco | read b; if test !!$b; cd (wghq root)/$b; end;'
    alias gch 'git branch -a --sort=-authordate | grep -v -E "\*|\->" | string trim | peco | read b; if test !!$b; git checkout $b; end;'
  end
  alias wklog "nvim ~/Documents/memo/2020-03-09-work-log.md"
  if type -q xsel
    alias xsel "xsel -b"
  end
  alias editdev "nvim ~/.dotfiles/Dockerfile"
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

  function idea
    idea.sh $argv > /var/log/idea.log 2>&1 &
  end
end


begin # key binding
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end
