set -x OS (uname -s)

# OS dependency
if test "$OS" = Darwin
  set -x IP (ifconfig en0 | grep -e "inet\s" | awk '$1=="inet" {print $2}')
else if test "$OS" = Linux
  set -l RELEASE (uname -r | string match -ir microsoft)
  if test -z "$HOST_OS" -a "$RELEASE" = microsoft
    set -x OS wsl
    set -x IP (ip route | head -n1 | awk '{print $3}')
  else if test "$HOST_OS" = Darwin
    set -x TERM screen-256color
  end
end


# fish
set -g $fish_emoji_width 2
alias fishconf "vim ~/.config/fish/config.fish"
alias fishload "source ~/.config/fish/config.fish"


# bobthefish
set -g theme_color_scheme gruvbox
set -g theme_show_exit_status yes


# SSH Agent
if test -z $SSH_AGENT_PID
  eval (ssh-agent -c) > /dev/null
  ssh-add $HOME/.ssh/id_rsa > /dev/null 2>&1
end


# X Window System
if type -q xhost
  xhost $IP > /dev/null 2>&1
end

# cf
if type -q cf; and type -q jq; and type -q peco
  function cflogin
    set -l endpoint (cat $HOME/.cf/endpoints.json | jq .[].endpoint | string trim -c "\"" | peco)
    set -l org (cat .cf/endpoints.json | jq ".[] | select(.endpoint == \"$endpoint\").org")
    if test !!$endpoint
      set -l passcode  (echo (echo $endpoint | string replace "api" "login")/passcode)
      if type -q xsel
        echo $passcode | xsel
      else if type -q pbcopy
        echo $passcode | pbcopy
      end
      cf login -a $endpoint --sso --skip-ssl-validation -o $org
    end
  end
end

# docker
if type -q docker
  set image_name "miya10kei/devenv"
  set container_name "miya10kei-devenv"
  set tag "latest"
  function rundev -d "Run docker container of dev..."
    set -l opts "\
              --cap-add=ALL \
              --name $container_name \
              --privileged=true \
              -v $HOME/.cache/JetBrains:/root/.cache/JetBrains \
              -v $HOME/.cf:/root/.cf \
              -v $HOME/.config/JetBrains:/root/.config/JetBrains \
              -v $HOME/.dotfiles:/root/.dotfiles \
              -v $HOME/.gradle:/root/.gradle \
              -v $HOME/.sbt:/root/.sbt \
              -v $HOME/.java:/root/.java \
              -v $HOME/.kube:/root/.kube \
              -v $HOME/.local/share/JetBrains:/root/.local/share/JetBrains \
              -v $HOME/.local/share/fish/fish_history:/root/.local/share/fish/fish_history \
              -v $HOME/.m2:/root/.m2 \
              -v $HOME/.ssh:/tmp/.ssh \
              -v $HOME/Documents:/root/Documents \
              -v $HOME/Downloads:/root/Downloads \
              -v $HOME/dev:/root/dev \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -e DISPLAY=$IP:0 \
              -e HOST_OS=$OS \
              -p 8000-9000:8000-9000 \
              -v /tmp/.X11-unix/:/tmp/.X11-unix \
              $argv"
    set -l cmd "docker run -dit $opts $image_name:$tag"
    echo $cmd | sed "s/ \{2,\}/ /g"
    eval $cmd
  end
  alias startdev "docker start $container_name"
  alias stopdev "docker stop $container_name; docker rm $container_name"
  alias attachdev "docker exec -it $container_name /usr/bin/fish"
  alias rmnoneimg "docker rmi (docker images -f 'dangling=true' -q)"
  alias editdev "vim ~/.dotfiles/Dockerfile"
  alias dk "docker"
end


# git
if type -q git; and type -q ghq; and type -q peco
  alias g "git"
  alias ghq "echo -ne \"🙅 Use of this command is prohibited.\nPlease use 'pghq' or 'wghq' command.\n\""
  alias pghq "echo -ne \"[ghq]\n  root = ~/dev/private\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
  alias wghq "echo -ne \"[ghq]\n  root = ~/dev/work\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
  function cdp -d "Change direcotry to the specified private repository."
    set -l repository (pghq list | peco)
    if test !!$repository
       cd (pghq root)/$repository
    end
  end
  function cdw -d "Change direcotry to the specified work repository."
    set -l repository (wghq list | peco)
    if test !!$repository
       cd (wghq root)/$repository
    end
  end
  function gch -d "Checkout the specified branch."
    set -l branch (git branch -a --sort=-authordate | grep -v -E "\*|\->" | string trim | peco)
    if test !!$branch
      if string match -rq '^remotes' $branch
        set -l remote (string replace -r 'remotes/' '' $branch)
        set -l new (string replace -r '[^/]*/' '' $remote)
        echo $newBranch
        git checkout -b $argv $new $remote
      else
        git checkout $argv $branch
      end
    end
  end
  alias delbr "git branch | grep -vE '\*|master|develop' | xargs git branch -D"
end


# IntelliJ IDEA
function idea -d "start IntelliJ IDEA"
  idea.sh $argv > /var/log/idea.log 2>&1 &
end


# Alias
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
alias wklog "vim ~/Documents/memo/2020-03-09-work-log.md"
alias cdot "cd ~/.dotfiles"
if type -q xsel
  alias xsel "xsel -b"
end
if type -q kubectl
  alias kube "kubectl"
end


# Util function
function decompress -d "Decompress the compressed file."
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
      case "*.zip" "*.jar"
        unzip $argv[1]
      case "*"
        echo "😰 I don't know how to decompress $argv[1] ..."
    end
  else
    echo "🙅 $argv[1] is not a compressed file"
  end
end

function loadenv -d "load .env file and run command passed as arguments"
  set cmd "env"
  for line in (cat $argv[1])
    if string match -qr "^#.*" $line
    else
      set cmd "$cmd $line"
    end
  end
  set cmd "$cmd $argv[2..-1]"
  echo $cmd
  eval $cmd
end


# Key binding
if type -q peco
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end
