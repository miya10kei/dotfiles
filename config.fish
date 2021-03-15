# --------------------------------------------------
# initial
# --------------------------------------------------
not status is-interactive; and exit


# --------------------------------------------------
# general
# --------------------------------------------------
set -x LANG en_US.utf8
set -x OS (uname -s)


# --------------------------------------------------
# fish
# --------------------------------------------------
set -g $fish_emoji_width 2


# --------------------------------------------------
# fisher
# --------------------------------------------------
if not type -q fisher
  echo "🚧 Installing fisher and plugins..."
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher > /dev/null
  if [ -e $HOME/.config/fish/fishfile ]
    fisher install < $HOME/.config/fish/fishfile > /dev/null
  end
  echo "👍 Complete to install fisher and plugins"
end


# --------------------------------------------------
# oh-my-fish theme-bobthefish
# --------------------------------------------------
set -g theme_color_scheme gruvbox
set -g theme_date_format "+%Y-%m-%d %H:%M:%S(%a)"
set -g theme_date_timezone Asia/Tokyo
set -g theme_display_docker_machine yes
set -g theme_show_exit_status yes

# --------------------------------------------------
# utility
# --------------------------------------------------
function alias-if-needed -a name -a command
  if set -q argv[3..-1]
    for require in $argv[3..-1]
      if not type -q $require
        return
      end
    end
  end
  alias $name $command
end

function decompress -d "Decompress the compressed file."
  if test -f $argv[1]
    switch $argv[1]
      case "*.tar.gz" "*.tgz"
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

function loadenv -d "Load .env file and run command passed as arguments"
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

function apply-completion -a commandName -d 'Apply command completion'
  set -l content (string join "\n" $argv[2..-1])
  echo -e $content > $HOME/.config/fish/completions/$commandName.fish
end

function addPath -a additionPath -d "Add new path into PATH variable"
  if not contains $additionPath $PATH
    set -x PATH $additionPath $PATH
  end
end


# --------------------------------------------------
# os dependency
# --------------------------------------------------
switch $OS
  case "Darwin"
    set -x IP (ifconfig en0 | grep -e "inet\s" | awk '$1=="inet" {print $2}')
    # java
    set -x JAVA_HOME /Library/Java/JavaVirtualMachines/liberica-jdk-11.jdk/Contents/Home
    # golang
    set -x GOPATH $HOME/go
    addPath $GOPATH/bin
    # nodejs
    set -x NODE_HOME $HOME/.nodebrew/current
    addPath $NODE_HOME/bin

    addPath /usr/local/opt/mysql-client/bin

    alias-if-needed edge "open -a Microsoft\ Edge"
    alias-if-needed excel "open -a Microsoft\ Excel"
    alias-if-needed readlink "greadlink"

  case "Linux"
    # java
    set -x JAVA_HOME "/usr/lib/jvm/bellsoft-java11-amd64"
    # golang
    set -x GO_HOME "/usr/local/go"
    addPath "$GO_HOME/bin"
    set -x GOPATH "$HOME/go"
    addPath "$GOPATH/bin"

    set -l RELEASE (uname -r | string match -ir microsoft)
    if test -z "$HOST_OS" -a "$RELEASE" = microsoft
      set -x OS wsl
      set -x IP (ip route | head -n1 | awk '{print $3}')
    else if test "$HOST_OS" = Darwin
      set -x TERM screen-256color
    end
end


# --------------------------------------------------
# ssh agent
# --------------------------------------------------
if test -z $SSH_AGENT_PID
  eval (ssh-agent -c) > /dev/null
  ssh-add $HOME/.ssh/id_rsa > /dev/null 2>&1
end


# --------------------------------------------------
# cf
# --------------------------------------------------
if type -q cf; and type -q jq; and type -q peco

  function cflogin
    set -l endpoint (cat $HOME/.cf/endpoints.json | jq .[].endpoint | string trim -c "\"" | peco)
    set -l org (cat $HOME/.cf/endpoints.json | jq ".[] | select(.endpoint == \"$endpoint\").org")
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


# --------------------------------------------------
# docker
# --------------------------------------------------
if type -q docker

  # $set $variableName $image $tag $containerName
  set baseDev    "miya10kei/base-dev"    "latest" "base-dev"
  set k8sDev     "miya10kei/k8s-dev"     "latest" "k8s-dev"
  set ansibleDev "miya10kei/ansible-dev" "latest" "ansible-dev"
  set devEnv     "miya10kei/devenv"      "latest" "devenv"
  set -l targets $baseDev[3] $k8sDev[3] $ansibleDev[3] $devEnv[3]

  function ctnr -d "Manipulate container"

    argparse -i -n ctnr "t/target=" -- $argv; or return 1

    switch $_flag_target
      case $baseDev[3]
        set image         $baseDev[1]
        set tag           $baseDev[2]
        set containerName $baseDev[3]
      case $k8sDev[3]
        set image         $k8sDev[1]
        set tag           $k8sDev[2]
        set containerName $k8sDev[3]
      case $ansibleDev[3]
        set image         $ansibleDev[1]
        set tag           $ansibleDev[2]
        set containerName $ansibleDev[3]
        set remoteUser    "ansible"
      case $devEnv[3]
        set image         $devEnv[1]
        set tag           $devEnv[2]
        set containerName $devEnv[3]
        set runOpts "\
              --cap-add=ALL \
              --privileged=true \
              -v $HOME/.cf:/root/.cf \
              -v $HOME/.dotfiles:/root/.dotfiles \
              -v $HOME/.gradle:/root/.gradle \
              -v $HOME/.sbt:/root/.sbt \
              -v $HOME/.java:/root/.java \
              -v $HOME/.kube:/root/.kube \
              -v $HOME/.m2:/root/.m2 \
              -v $HOME/.ssh:/tmp/.ssh \
              -v $HOME/Documents:/root/Documents \
              -v $HOME/Downloads:/root/Downloads \
              -v $HOME/dev:/root/dev \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -e DISPLAY=$IP:0 \
              -e HOST_OS=$OS"
              #-v $HOME/.cache/JetBrains:/root/.cache/JetBrains \
              #-v $HOME/.config/JetBrains:/root/.config/JetBrains \
              #-v $HOME/.Xauthority:/root/.Xauthority \
              #-v $HOME/.local/share/JetBrains:/root/.local/share/JetBrains \
              #-v $HOME/.local/share/fish/fish_history:/root/.local/share/fish/fish_history \
              #-v /tmp/.X11-unix/:/tmp/.X11-unix \
      case "*"
        echo "🙅 Not support container: $_flag_target"
        return 1
    end

    not set -q remoteUser; and set -l remoteUser $USER
    set remoteHome "/home/$remoteUser"
    set subCommand $argv[1]

    switch $subCommand
      case "run"
        set -l uid (id -u)
        set -l gid (id -g)
        set runOpts "\
              --name $containerName \
              -e REMOTE_GID=$gid \
              -e REMOTE_UID=$uid \
              -e REMOTE_USER=$remoteUser \
              -v $HOME/.config/fish/config.fish:$remoteHome/.config/fish/config.fish:ro \
              -v $HOME/.config/fish/fishfile:$remoteHome/.config/fish/fishfile:ro \
              -v $HOME/.local/share/fish/fish_history:$remoteHome/.local/share/fish/fish_history \
              -v $HOME/.ssh:$remoteHome/.ssh \
              $runOpts \
              $argv[2..-1] \
              "
        set cmd "docker run -dit $runOpts $image:$tag"
      case "attach"
        set attachOpts "\
              -u $remoteUser \
              -w $remoteHome \
              $attachOpts \
              $argv[2..-1] \
              "
        set cmd "docker exec -it $attachOpts $containerName /usr/bin/fish"
      case "start"
        set cmd "docker start $containerName"
      case "stop"
        set cmd "docker stop $containerName && docker rm $containerName"
      case "*"
        echo "🙅 Unsupported sub-command: $subCommand"
        return 1
    end

    echo $cmd | sed "s/ \{2,\}/ /g"
    eval $cmd
  end

  # completion
  set -l targetAlias (string join ' ' $targets)
  set -l cntrCompletion \
        "complete -f -c ctnr -n '__fish_use_subcommand' -a 'run'    -d 'Run container'" \
        "complete -f -c ctnr -n '__fish_use_subcommand' -a 'attach' -d 'Attach to container'" \
        "complete -f -c ctnr -n '__fish_use_subcommand' -a 'start'  -d 'Start container'" \
        "complete -f -c ctnr -n '__fish_use_subcommand' -a 'stop'   -d 'Stop and remove container'" \
        "complete -x -c ctnr -s t -l target -a '$targetAlias' -d 'Target container'"
  apply-completion "ctnr" $cntrCompletion

  alias-if-needed rmnoneimg "docker rmi (docker images -f 'dangling=true' -q)"
end


# --------------------------------------------------
# git
# --------------------------------------------------
#
if type -q git; and type -q ghq; and type -q peco

  alias-if-needed ghq "echo -ne \"🙅 Use of this command is prohibited.\nPlease use 'pghq' or 'wghq' command.\n\""
  alias-if-needed pghq "echo -ne \"[ghq]\n  root = ~/dev/private\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
  alias-if-needed wghq "echo -ne \"[ghq]\n  root = ~/dev/work\" > ~/.gitconfig_ghq; $GOPATH/bin/ghq"
  alias-if-needed delbr "git branch | grep -vE '\*|master|develop' | xargs git branch -D"

  function gitt -a subCommand
    switch $subCommand
      case "cd"
        switch $argv[2]
          case "private"
            set -l repository (pghq list | peco)
            set cmd "test !!$repository; and cd (pghq root)/$repository"
          case "work"
            set -l repository (wghq list | peco)
            set cmd "test !!$repository; and cd (wghq root)/$repository"
          case "*"
            echo "🙅 Unsupported repository: $argv[2]"
            return 1
          end
      case "checkout" "ch"
        set -l branch (git branch -a --sort=-authordate | grep -v -E "\*|\->" | string trim | peco)
        if test !!$branch
          if string match -rq '^remotes' $branch
            set -l remote (string replace -r 'remotes/' '' $branch)
            set -l new (string replace -r '[^/]*/' '' $remote)
            set cmd "git checkout -b $new $remote"
          else
            set cmd "git checkout $branch"
          end
        end
      case "*"
        echo "🙅 Unsupported sub-command: $subCommand"
        return 1
    end
    eval $cmd
  end

  # completion
  set -l gittCompletion \
        "complete -f -c gitt -n '__fish_use_subcommand'          -a 'cd'       -d 'Change directory of git'" \
        "complete -f -c gitt -n '__fish_use_subcommand'          -a 'checkout' -d 'Checkout branch'" \
        "complete -f -c gitt -n '__fish_seen_subcommand_from cd' -a 'private'  -d 'Change directory of private git'" \
        "complete -f -c gitt -n '__fish_seen_subcommand_from cd' -a 'work'     -d 'Change directory of work git'"
  apply-completion "gitt" $gittCompletion
end


# --------------------------------------------------
# alias
# --------------------------------------------------
alias-if-needed cdevp      "cd $HOME/dev/private"
alias-if-needed cdevw      "cd $HOME/dev/work"
alias-if-needed cdot       "cd $HOME/.dotfiles"
alias-if-needed cdr        "cd -"
alias-if-needed epochtime  "date -u +%s"
alias-if-needed fishconf   "vim ~/.config/fish/config.fish"
alias-if-needed fishload   "source ~/.config/fish/config.fish"
alias-if-needed idea       "intellij-idea-ultimate" "intellij-idea-ultimate"
alias-if-needed ll         "ls -hlF"
alias-if-needed lla        "ls -ahlF"
alias-if-needed ls         "ls -hF"
alias-if-needed lsa        "ls -ahF"
alias-if-needed mv         "mv -i"
alias-if-needed mvnwrapper "mvn -N io.takari:maven:wrapper" "mvn"
alias-if-needed q          "exit"
alias-if-needed rm         "rm -i"
alias-if-needed rr         "rm -ri"
alias-if-needed rrf        "rm -rf"
alias-if-needed u          "cd ../"
alias-if-needed uu         "cd ../../"
alias-if-needed uuu        "cd ../../../"
alias-if-needed uuuu       "cd ../../../../"
alias-if-needed vim        "nvim"
alias-if-needed vims       "vim (fzf)"
alias-if-needed xsel       "xsel -b"


# --------------------------------------------------
# key binding
# --------------------------------------------------
if type -q peco
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end

