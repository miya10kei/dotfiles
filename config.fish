# --------------------------------------------------
# initial
# --------------------------------------------------
status is-interactive; or exit


# --------------------------------------------------
# general
# --------------------------------------------------
set -q SHELL; or set -x SHELL /usr/bin/fish
set -x LANG ja_JP.UTF-8
set -x OS    (uname -s)
switch $TERM
  case "xterm"
    set -x TERM "xterm-256color"
  case "screen"
    set -x TERM "screen-256color"
end


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
set -g theme_color_scheme           gruvbox
set -g theme_date_format            "+%Y-%m-%d %H:%M:%S(%a)"
set -g theme_date_timezone          Asia/Tokyo
set -g theme_display_docker_machine yes
set -g theme_display_user           yes
set -g theme_show_exit_status       yes


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

function addPath -a target -d "Add new path into PATH variable"
  if not contains $target $PATH
    set -x PATH $target $PATH
  end
end

function removePath -a target -d "Remove path from PATH variable"
  for p in $PATH
    if test "$p" != "$target"
      set newPath $newPath $p
    end
  end
  set -x PATH $newPath
end


# --------------------------------------------------
# os dependency
# --------------------------------------------------
switch $OS
  case "Darwin"
    set -x IP (ifconfig en0 | grep -e "inet\s" | awk '$1=="inet" {print $2}')
    # nodejs
    set -x NODE_HOME $HOME/.nodebrew/current
    addPath $NODE_HOME/bin

    addPath /usr/local/opt/mysql-client/bin

    alias-if-needed edge "open -a Microsoft\ Edge"
    alias-if-needed excel "open -a Microsoft\ Excel"
    alias-if-needed readlink "greadlink"
  case "Linux"
    set -l RELEASE (uname -r | string match -ir microsoft)
    if test -z "$HOST_OS" -a "$RELEASE" = microsoft
      set -x OS wsl
      set -x IP (ip route | head -n1 | awk '{print $3}')
    else if test "$HOST_OS" = Darwin
      set -x TERM screen-256color
    end
end


# --------------------------------------------------
# language configuration
# --------------------------------------------------
# java
# --------------------------------------------------
switch $OS
  case "Darwin"
    set jvmDir /Library/Java/JavaVirtualMachines
  case "Linux"
    set jvmDir /usr/lib/jvm
end

if test -e $jvmDir
  function jenv -a subCommand
    argparse -i -n jenv "q/quit" -- $argv; or return 1

    switch $subCommand
      case "current"
        argparse -i -n jenv "p/path" -- $argv; or return 1
        if test -n "$_flag_path"
          echo $JAVA_HOME
        else
          $JAVA_HOME/bin/java -version
        end
      case "latest" "set"
        if [ $subCommand = "latest" ]
          set newJavaHome (ls -f1d $jvmDir/* | tail -1 | string trim -r -c "/")
        else
          if test -n "$argv[2]"
            if test -e "$argv[2]"
              set newJavaHome $argv[2]
            else
              echo "🙅 Specified java version is not found: $argv[2]"
              return 1
            end
          else
            set newJavaHome (ls -fd $jvmDir/* | string trim -r -c "/" | peco)
          end
        end
        if [ -n "$newJavaHome" ]
          test $OS = "Darwin" && set newJavaHome $newJavaHome/Contents/Home
          removePath $JAVA_HOME/bin
          set -xg JAVA_HOME "$newJavaHome"
          addPath $JAVA_HOME/bin
          if test -z "$_flag_quit"
            set_color green && echo "☕ Applied: $JAVA_HOME" && set_color normal
          end
        end
      case "*"
        echo "🙅 Unsupported sub-command: $subCommand"
        return 1
    end
  end
  set -l jenvCompletion \
        "complete -f -c jenv -n '__fish_use_subcommand' -a 'current' -d 'Show current java version'" \
        "complete -f -c jenv -n '__fish_use_subcommand' -a 'latest'  -d 'Set latest Java version'" \
        "complete -f -c jenv -n '__fish_use_subcommand' -a 'set'     -d 'Select Java version and set it'" \
        "complete -f -c jenv -n '__fish_seen_subcommand_from current' -s p -l path -d 'Show current JAVA_HOME'" \
        "complete -f -c jenv -n '__fish_seen_subcommand_from latest'  -s q -l quit -d 'Not display message'" \
        "complete -f -c jenv -n '__fish_seen_subcommand_from set'     -s q -l quit -d 'Not display message'"
  apply-completion "jenv" $jenvCompletion

  function change-java-version-depends-on-version-file
    set -l versionFile "$argv[1]/.java_version"
    if ls -1 $versionFile > /dev/null 2>&1
      set -l newVersion (cat $versionFile | head -n 1)
      if not string match -rq "$newVersion.*" (jenv current -p)
        jenv set $newVersion
      end
    else
      if test \( "$argv" != "$HOME" \) -a \( "$argv[1]" != "/" \)
        change-java-version-depends-on-version-file (dirname $argv[1])
      end
    end
  end

  not set -q JAVA_HOME && jenv latest -q
end
# --------------------------------------------------
# golang
# --------------------------------------------------
switch $OS
  case "Darwin"
    set -x GOPATH $HOME/go
    addPath $GOPATH/bin
  case "Linux"
    if test -e /usr/local/go
      set -x GO_HOME "/usr/local/go"
      addPath "$GO_HOME/bin"
      set -x GOPATH "$HOME/go"
      addPath "$GOPATH/bin"
    end
end
# --------------------------------------------------
# nodejs
# --------------------------------------------------
if type -q node; and type -q npm
  set -x NODE_MODULE $HOME/node_modules
  addPath $NODE_MODULE/.bin
  set -ag backgroundCmds "pushd $HOME \
                          && npm install --global-style \
                                         --ignore-scripts \
                                         --no-package-lock \
                                         --only=prod \
                                         --loglevel=error \
                                         > /dev/null \
                          && popd"
end


# --------------------------------------------------
# ssh agent
# --------------------------------------------------
if test -z $SSH_AGENT_PID
  exec ssh-agent $SHELL
end

if not ssh-add -l > /dev/null
  ssh-add (ls $HOME/.ssh/id_rsa* | grep -Ev '(\.pub|\.bk)$') > /dev/null 2>&1
end


# --------------------------------------------------
# cf
# --------------------------------------------------
if type -q cf; and type -q jq; and type -q peco
  function cff -a subCommand
    switch $subCommand
      case "env"
        argparse -n cff "c/copy" -- $argv; or return 1
        set -l app (cf apps | tail -n +5 | awk '{print($1)}' | peco) && test -z $app && return
        if test -z "$_flag_copy"
          set cmd "cf env $app"
        else
          set -a envs "VCAP_SERVICES="(LANG=C cf env $app \
                        | awk -v RS= -v ORS='\n\n' '/System-Provided:/' \
                        | awk 'BEGIN{lines=""}NR>1{lines=lines$0}END{print lines}' \
                        | jq .VCAP_SERVICES -c -M
                     )
          for env in (LANG=C cf env $app \
                          | awk -v RS= -v ORS='\n\n' '/User-Provided:/' \
                          | awk '/./{print $0}' \
                          | awk -F ': ' 'NR>1 {sub(": ", "="); print $0}'
                       )
            set -a envs $env
          end
          set cmd "string collect -N '$envs' | pbcopy"
        end

      case "log" "logs"
        set -l app (cf apps | tail -n +5 | awk '{print($1)}' | peco) && test -z $app && return
        set cmd "cf logs $app"

      case "login"
        set endpoint (jq -r ".[]" $HOME/.cf/endpoints.json | peco) && test -z $endpoint && return
        open "https://login.$endpoint/passcode"
        set cmd "cf login --sso -a https://api.$endpoint"

      case "open"
        set endpoint (jq -r ".[]" $HOME/.cf/endpoints.json | peco) && test -z $endpoint && return
        set cmd "open https://apps.$endpoint"

      case "ssh"
        set -l app (cf apps | tail -n +5 | awk '{print($1)}' | peco) && test -z $app && return
        set cmd "cf ssh $app"

      case "switch" "sw"
        argparse -n cff "t/target=" -- $argv; or return 1
        switch $_flag_target
          case "org" "orgs" "o"
            set -l org (cf orgs| tail -n +4 | peco) && test -z $org && return
            set cmd "cf target -o $org"
          case "space" "spaces" "s"
            set space (cf spaces | tail -n +4 | peco) && test -z $space && return
            set cmd "cf target -s $space"
          case "*"
            echo "🙅 Unsupported option value: $_flag_target"
            return 1
        end

      case "*"
        echo "🙅 Unsupported sub-command: $subCommand"
        return 1
    end

    set_color green && echo "🐟 $cmd" | sed "s/ \{2,\}/ /g" && set_color normal
    eval $cmd
  end

  set -l cffCompletion \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'env'     -d 'show app enviroment values'" \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'log'     -d 'tail app log'" \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'login'   -d 'login cloud foundry'" \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'open'    -d 'open Apps Manager'" \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'ssh'     -d 'ssh app'" \
        "complete -f -c cff -n '__fish_use_subcommand' -a 'switch'  -d 'switch org or space'" \
        "complete -f -c cff -n '__fish_seen_subcommand_from env'    -s c -l copy   -d 'Copy into clipboard'" \
        "complete -x -c cff -n '__fish_seen_subcommand_from switch' -s t -l target -a 'org space' -d 'target to switch'"
  apply-completion "cff" $cffCompletion
end


# --------------------------------------------------
# docker
# --------------------------------------------------
if type -q docker

  #   $variableName $image                  $tag     $containerName
  set baseDev       "miya10kei/base-dev"    "latest" "base-dev"
  set k8sDev        "miya10kei/k8s-dev"     "latest" "k8s-dev"
  set ansibleDev    "miya10kei/ansible-dev" "latest" "ansible-dev"
  set vaultDev      "miya10kei/vault-dev"   "latest" "vault-dev"
  set devEnv        "miya10kei/devenv"      "latest" "devenv"
  set -l targets $baseDev[3] $k8sDev[3] $ansibleDev[3] $vaultDev[3] $devEnv[3]

  function ctnr -d "Manipulate container"

    argparse -i -n ctnr "t/target=" "a/attach" "r/recreate" -- $argv; or return 1

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
        set runOpts       "\
                            -v $HOME/.ansible.cfg:/home/$remoteUser/.ansible.cfg \
                          "
      case $vaultDev[3]
        set image         $vaultDev[1]
        set tag           $vaultDev[2]
        set containerName $vaultDev[3]
        set runOpts       "\
                            --cap-add=IPC_LOCK \
                            -e VAULT_ADDR=http://vault1:8200 \
                          "
      case $devEnv[3]
        set image         $devEnv[1]
        set tag           $devEnv[2]
        set containerName $devEnv[3]
        set runOpts       "\
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
                            -e HOST_OS=$OS
                          "
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

    set -q remoteUser; or set -l remoteUser $USER
    set remoteHome "/home/$remoteUser"
    set subCommand $argv[1]

    switch $subCommand
      case "run"
        set -l uid  (id -u)
        set -l gid  (id -g)
        set runOpts "\
                      --name $containerName \
                      -e DOCKER_MACHINE_NAME='🐳 $containerName' \
                      -e REMOTE_GID=$gid \
                      -e REMOTE_UID=$uid \
                      -e REMOTE_USER=$remoteUser \
                      -h $containerName \
                      -v $HOME/.config/coc/extensions/package.json:$remoteHome/.config/coc/extensions/package.json \
                      -v $HOME/.config/fish/config.fish:$remoteHome/.config/fish/config.fish \
                      -v $HOME/.config/fish/fishfile:$remoteHome/.config/fish/fishfile \
                      -v $HOME/.config/nvim/coc-settings.json:$remoteHome/.config/nvim/coc-settings.json \
                      -v $HOME/.config/nvim/init.vim:$remoteHome/.config/nvim/init.vim \
                      -v $HOME/.local/share/fish/fish_history:$remoteHome/.local/share/fish/fish_history \
                      -v $HOME/.npmrc:$remoteHome/.npmrc \
                      -v $HOME/.ssh:$remoteHome/.ssh \
                      -v $HOME/dev:$remoteHome/dev \
                      -v $HOME/package.json:$remoteHome/package.json \
                      $runOpts \
                      $argv[2..-1] \
                    "
        set cmd     "docker run -dit $runOpts $image:$tag /usr/bin/bash"
        test -n "$_flag_recreate"
          and test (docker container ls -qa -f name="$containerName")
          and set beforeCmd "ctnr stop -t $containerName"
        test -n "$_flag_attach"; and set afterCmd "ctnr attach -t $containerName"
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

    test -n $beforeCmd; eval $beforeCmd
    set_color green && echo "🐟 $cmd" | sed "s/ \{2,\}/ /g" && set_color normal
    eval $cmd
    test -n $afterCmd && sleep 0.5 && eval $afterCmd
  end

  # completion
  set -l targetAlias (string join ' ' $targets)
  set -l cntrCompletion \
    "complete -f -c ctnr -n '__fish_use_subcommand' -a 'run'    -d 'Run container'" \
    "complete -f -c ctnr -n '__fish_seen_subcommand_from run' -s a -l attach   -d 'execute attach after run'" \
    "complete -f -c ctnr -n '__fish_seen_subcommand_from run' -s r -l recreate -d 'recreate container if already exists'" \
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
        "complete -f -c gitt -n '__fish_use_subcommand'          -a 'ch'       -d 'Checkout branch'" \
        "complete -f -c gitt -n '__fish_seen_subcommand_from cd' -a 'private'  -d 'Change directory of private git'" \
        "complete -f -c gitt -n '__fish_seen_subcommand_from cd' -a 'work'     -d 'Change directory of work git'"
  apply-completion "gitt" $gittCompletion
end


# --------------------------------------------------
# neovim
# --------------------------------------------------
if type -q nvim
  set -x  NVIM_HOME      $HOME/.config/nvim
  set -ag backgroundCmds "nvim --headless +PlugInstall +qa > /dev/null 2>&1"
  set -ag backgroundCmds "pushd $HOME/.config/coc/extensions \
                          && npm install --global-style \
                                         --ignore-scripts \
                                         --loglevel=error \
                                         --no-bin-links \
                                         --no-package-lock \
                                         --only=prod \
                                         > /dev/null \
                          && popd"
end


# --------------------------------------------------
# package manager
# --------------------------------------------------
function package -a subCommand -d "manage package"
  switch $subCommand
    case "update"
      switch $OS
        case "Darwin"
          set -a cmds "brew update && brew upgrade"
        case "Linux"
          set -a cmds "sudo apt update && sudo apt upgrade && sudo apt autoremove"
      end
      set -a cmds "fisher update"
      set -a cmds "pushd $HOME && ncu -u && npm update && popd"
      set -a cmds "pushd $HOME/.config/coc/extensions && ncu -u && npm update && popd"
      set -a cmds "nvim --headless +PlugUpgrade +PlugUpdate +qa"
    case "*"
      echo "🙅 Unsupported sub-command: $subCommand"
      return 1
  end

  for cmd in $cmds
    set_color green && echo "🐟 $cmd" | sed "s/ \{2,\}/ /g" && set_color normal
    eval $cmd
  end
end
set -l packageCompletion "complete -f -c package -n '__fish_use_subcommand' -a 'update' -d 'update some installed package'"
apply-completion "package" $packageCompletion


# --------------------------------------------------
# event
# --------------------------------------------------
function cd-with-event
  builtin cd $argv
  emit cd-event (pwd)
end

function cd-event-listener --on-event cd-event
  if type -q change-java-version-depends-on-version-file
    change-java-version-depends-on-version-file $argv[1]
  end
end


# --------------------------------------------------
# alias
# --------------------------------------------------
alias-if-needed cd         "cd-with-event"
alias-if-needed cdevp      "cd $HOME/dev/private"
alias-if-needed cdevw      "cd $HOME/dev/work"
alias-if-needed cdot       "cd $HOME/.dotfiles"
alias-if-needed cdr        "cd -"
alias-if-needed epochtime  "date -u +%s"
alias-if-needed fishconf   "vim $HOME/.config/fish/config.fish"
alias-if-needed fishload   "source $HOME/.config/fish/config.fish"
alias-if-needed thistory    "history --show-time='%Y-%m-%d %H:%M:%S  '"
alias-if-needed idea       "intellij-idea-ultimate" "intellij-idea-ultimate"
if ls --color > /dev/null 2>&1
  alias-if-needed ll       "ls --color -hlFG"
  alias-if-needed lla      "ls --color -ahlFG"
  alias-if-needed ls       "ls --color -hFG"
  alias-if-needed lsa      "ls --color -ahFG"
else
  alias-if-needed ll       "ls -hlFG"
  alias-if-needed lla      "ls -ahlFG"
  alias-if-needed ls       "ls -hFG"
  alias-if-needed lsa      "ls -ahFG"
end
alias-if-needed mv         "mv -i"
alias-if-needed mvnwrapper "mvn -N io.takari:maven:wrapper" "mvn"
alias-if-needed q          "exit"
alias-if-needed rm         "rm -i"
alias-if-needed rr         "rm -ri"
alias-if-needed rrf        "rm -rf"
alias-if-needed tmuxconf   "vim $HOME/.tmux.conf"
alias-if-needed u          "cd ../"
alias-if-needed uu         "cd ../../"
alias-if-needed uuu        "cd ../../../"
alias-if-needed uuuu       "cd ../../../../"
alias-if-needed vim        "nvim"
alias-if-needed xsel       "xsel -b"


# --------------------------------------------------
# backgroun process
# --------------------------------------------------
if not test -e $HOME/.lastinstalled
  epochtime > $HOME/.lastinstalled

  for cmd in $backgroundCmds
    set_color green && echo "🐡 $cmd" | sed "s/ \{2,\}/ /g" && set_color normal
    fish -c "$cmd" &
  end
end


# --------------------------------------------------
# key binding
# --------------------------------------------------
if type -q peco
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end

