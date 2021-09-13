# --------------------------------------------------
# initial
# --------------------------------------------------
status is-interactive; or exit


# --------------------------------------------------
# general
# --------------------------------------------------
set -q SHELL; or set -x SHELL /usr/bin/fish
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
  echo \uf0ed" Installing fisher and plugins..."
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher > /dev/null
  if [ -e $HOME/.config/fish/fishfile ]
    fisher install < $HOME/.config/fish/fishfile > /dev/null
  end
  echo \ufa12" Complete to install fisher and plugins"
end


# --------------------------------------------------
# oh-my-fish theme-bobthefish
# --------------------------------------------------
set -g theme_color_scheme           gruvbox
set -g theme_date_format            "+%Y-%m-%d %H:%M:%S(%a)"
set -g theme_date_timezone          Asia/Tokyo
set -g theme_display_docker_machine yes
set -g theme_display_user           yes
set -g theme_nerd_fonts             yes
set -g theme_newline_cursor         yes
set -g theme_newline_prompt         \uf739' '
set -g theme_powerline_fonts        no
set -g theme_show_exit_status       yes

function fish_greeting
  set_color $fish_color_autosuggestion
  echo \uf90a" Live as if you were to die tomorrow. Learn as if you were to live forever."
  set_color normal
end


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

function bind-if-available -a key -a command
  if type -q $command
    if test -z $key
      $command
    else
      bind $key $command
    end
  end
end

function compress -a format -a target -d "Compress the file or directory"
  test -z "$target" && echo \uf05c" You must pass the target file/directory"
  switch $format
    case "tar.gz"
      tar -zcvf "$target.$format" $target
    case "zip"
      zip "$target.$format" $target
    case "*"
      echo \uf05c" I don't knw $format ..."
  end
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
        echo \uf05c" I don't know how to decompress $argv[1] ..."
    end
  else
    echo \uf05c" $argv[1] is not a compressed file"
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
  if test -e $target
    if not contains $target $PATH
      set -x PATH $target $PATH
    end
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

function execCmd -a CMD
    set_color green
    echo \uf739" $CMD" | sed "s/ \{2,\}/ /g"
    set_color normal
    eval $CMD
end


# --------------------------------------------------
# os dependency
# --------------------------------------------------
switch $OS
  case "Darwin"
    set -x IP (ifconfig en0 | grep -E "inet\s" | awk '$1=="inet" {print $2}')

    addPath /usr/local/opt/mysql-client/bin
    addPath /usr/local/sbin

    alias-if-needed edge "open -a Microsoft\ Edge"
    alias-if-needed excel "open -a Microsoft\ Excel"
    alias-if-needed readlink "greadlink" "greadlink"
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
if test -e $HOME/.sdkman
  function sdk
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk $argv"
  end

  for ITEM in $HOME/.sdkman/candidates/* ;
    addPath $ITEM/current/bin
  end
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
end

# --------------------------------------------------
# rust
# --------------------------------------------------
addPath $HOME/.cargo/bin


# --------------------------------------------------
# ssh agent
# --------------------------------------------------
if test -z $SSH_AGENT_PID
  exec ssh-agent $SHELL
end

if not ssh-add -l > /dev/null
  if  test -e $HOME/.ssh/id_rsa
    ssh-add (ls -l1 $HOME/.ssh/id_rsa* | grep -Ev '(\.pub|\.bk)$') > /dev/null 2>&1
  end
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
            echo \uf05c" Unsupported option value: $_flag_target"
            return 1
        end

      case "*"
        echo \uf05c" Unsupported sub-command: $subCommand"
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

  #   $variableName $image $tag $containerName
  #set DEV_ENV "ghcr.io/miya10kei/dev-env" "latest" "dev-env"
  set DEV_ENV "cd.docker-registry.corp.yahoo.co.jp:4443/kmiyaush/dev-env-inhouse" "latest" "dev-env"

  set TARGETS $DEV_ENV[3]

  function ctnr -d "Manipulate container"

    argparse -i -n ctnr "t/target=" "a/attach" "r/recreate" -- $argv; or return 1

    set REMOTE_HOME /home/$USER
    set SUB_COMMAND $argv[1]

    switch $_flag_target
      case $DEV_ENV[3]
        set IMAGE_NAME     $DEV_ENV[1]
        set TAG_NAME       $DEV_ENV[2]
        set CONTAINER_NAME $DEV_ENV[3]
      case "*"
        echo \uf05c" Not support container: $_flag_target"
        return 1
    end

    switch $SUB_COMMAND
      case "run"
        set RUN_OPTS "--name $CONTAINER_NAME \
                      -e DISPLAY \
                      -e DOCKER_MACHINE_NAME='"\ue7b0" $CONTAINER_NAME' \
                      -e REMOTE_USER=$REMOTE_USER\
                      -h $CONTAINER_NAME \
                      --mount type=bind,src=$HOME/.dotfiles,dst=$REMOTE_HOME/.dotfiles \
                      --mount type=bind,src=$HOME/.dotfiles/.editorconfig,dst=$REMOTE_HOME/.editorconfig \
                      --mount type=bind,src=$HOME/.dotfiles/.gitconfig,dst=$REMOTE_HOME/.gitconfig \
                      --mount type=bind,src=$HOME/.dotfiles/.gitconfig_private,dst=$REMOTE_HOME/.gitconfig_private \
                      --mount type=bind,src=$HOME/.dotfiles/.npmrc,dst=$REMOTE_HOME/.npmrc \
                      --mount type=bind,src=$HOME/.dotfiles/.tmux.conf,dst=$REMOTE_HOME/.tmux.conf\
                      --mount type=bind,src=$HOME/.dotfiles/coc-package.json,dst=$REMOTE_HOME/.config/coc/extensions/package.json \
                      --mount type=bind,src=$HOME/.dotfiles/coc-settings.json,dst=$REMOTE_HOME/.config/nvim/coc-settings.json \
                      --mount type=bind,src=$HOME/.dotfiles/config.fish,dst=$REMOTE_HOME/.config/fish/config.fish \
                      --mount type=bind,src=$HOME/.dotfiles/fishfile,dst=$REMOTE_HOME/.config/fish/fishfile \
                      --mount type=bind,src=$HOME/.dotfiles/init.vim,dst=$REMOTE_HOME/.config/nvim/init.vim \
                      --mount type=bind,src=$HOME/.dotfiles/package.json,dst=$REMOTE_HOME/package.json \
                      --mount type=bind,src=$HOME/.devenv/fish/fish_history,dst=$REMOTE_HOME/.local/share/fish/fish_history \
                      --mount type=bind,src=$HOME/.devenv/gradle,dst=$REMOTE_HOME/.gradle \
                      --mount type=bind,src=$HOME/.devenv/idea/cache,dst=$REMOTE_HOME/.cache/JetBrains \
                      --mount type=bind,src=$HOME/.devenv/idea/config,dst=$REMOTE_HOME/.config/JetBrains \
                      --mount type=bind,src=$HOME/.devenv/idea/local,dst=$REMOTE_HOME/.local/share/JetBrains \
                      --mount type=bind,src=$HOME/.devenv/java,dst=$REMOTE_HOME/.java \
                      --mount type=bind,src=$HOME/.devenv/maven,dst=$REMOTE_HOME/.m2 \
                      --mount type=bind,src=$HOME/.ssh,dst=$REMOTE_HOME/.ssh \
                      --mount type=bind,src=$HOME/Documents,dst=$REMOTE_HOME/Documents \
                      --mount type=bind,src=$HOME/Downloads,dst=$REMOTE_HOME/Downloads \
                      --mount type=bind,src=$HOME/dev,dst=$REMOTE_HOME/dev \
                      --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
                      --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
                      $RUN_OPTS \
                      $argv[2..-1]"

        set DOCKER_GID (cat /etc/group | grep docker | awk -F: '{print($3)}')
        if test -n "$DOCKER_GID"
          set RUN_OPTS "-e DOCKER_GID=$DOCKER_GID $RUN_OPTS"
        end

        set CMD "docker run -dit $RUN_OPTS $IMAGE_NAME:$TAG_NAME /usr/bin/bash"
        if test -n "$_flag_recreate"
          if test (docker container ls -qa -f name="$CONTAINER_NAME")
            set PRE_CMD "ctnr stop -t $CONTAINER_NAME"
          end
        end
        if test -n "$_flag_attach"
          set POST_CMD "ctnr attach -t $CONTAINER_NAME"
        end

      case "attach"
        set ATTACH_OPTS "$argv[2..-1]"
        set CMD "docker exec -it $ATTACH_OPTS $CONTAINER_NAME /usr/bin/fish"

      case "start"
        set CMD "docker start $CONTAINER_NAME"

      case "stop"
        set CMD "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"

      case "*"
        echo \uf05c" Unsupported sub-command:$SUB_COMMAND"
        return 1
    end

    if test -n "$PRE_CMD"
      execCmd $PRE_CMD
    end
    execCmd $CMD
    if test -n "$POST_CMD"
      execCmd $POST_CMD
    end
  end

  # completion
  set -l TARGET_ALIAS (string join ' ' $TARGETS)
  set -l CNTR_COMPLETION \
    "complete -f -c ctnr -n '__fish_use_subcommand' -a 'run'    -d 'Run container'" \
    "complete -f -c ctnr -n '__fish_seen_subcommand_from run' -s a -l attach   -d 'execute attach after run'" \
    "complete -f -c ctnr -n '__fish_seen_subcommand_from run' -s r -l recreate -d 'recreate container if already exists'" \
    "complete -f -c ctnr -n '__fish_use_subcommand' -a 'attach' -d 'Attach to container'" \
    "complete -f -c ctnr -n '__fish_use_subcommand' -a 'start'  -d 'Start container'" \
    "complete -f -c ctnr -n '__fish_use_subcommand' -a 'stop'   -d 'Stop and remove container'" \
    "complete -x -c ctnr -s t -l target -a '$TARGET_ALIAS' -d 'Target container'"
  apply-completion "ctnr" $CNTR_COMPLETION

  alias-if-needed rmnoneimg "docker rmi (docker images -f 'dangling=true' -q)"
end


# --------------------------------------------------
# fzf
# --------------------------------------------------
if type -q fzf
  # morhetz/gruvbox
  set -l FZF_COLOR              'bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'
  set -x FZF_DEFAULT_OPTS       "--layout=reverse --height=80% --border --margin=1 --padding=1 --info=inline --color=$FZF_COLOR"
  set -l FZF_PREVIEW_BAT_OPTION '--style=numbers --color=always --theme=TwoDark --line-range :500 {}'
  set FZF_CTRL_T_OPTS           "--preview='bat $FZF_PREVIEW_BAT_OPTION' --preview-window right:70%"
end


# --------------------------------------------------
# neovim
# --------------------------------------------------
if type -q nvim
  set -x  NVIM_HOME      $HOME/.config/nvim
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
      echo \uf05c" Unsupported sub-command: $subCommand"
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
# alias
# --------------------------------------------------
alias-if-needed catt       "bat --style=numbers --color=always --theme=TwoDark" "bat"
alias-if-needed cdevp      "cd $HOME/dev/private"
alias-if-needed cdevw      "cd $HOME/dev/work"
alias-if-needed cdot       "cd $HOME/.dotfiles"
alias-if-needed cdr        "cd -"
alias-if-needed difff      "delta" "delta"
alias-if-needed dk         "docker" "docker"
alias-if-needed epochtime  "date -u +%s"
alias-if-needed findd      "fdfind" "fdfind"
alias-if-needed fishconf   "vim $HOME/.config/fish/config.fish"
alias-if-needed fishload   "source $HOME/.config/fish/config.fish"
alias-if-needed g          "git_fish" "git_fish"
alias-if-needed grepp      "rg" "rg"
alias-if-needed ll         "ls -lg"
alias-if-needed lla        "ll -a"
alias-if-needed ls         "exa" "exa"
alias-if-needed lsa        "ls -a"
alias-if-needed k          "kubectl" "kubectl"
alias-if-needed mv         "mv -i"
alias-if-needed mvnwrapper "mvn -N io.takari:maven:wrapper" "mvn"
alias-if-needed odd        "hexyl" "hexyl"
alias-if-needed pss        "procs" "procs"
alias-if-needed q          "exit"
alias-if-needed rm         "rm -i"
alias-if-needed rr         "rm -ri"
alias-if-needed rrf        "rm -rf"
alias-if-needed thistory   "history --show-time='%Y-%m-%d %H:%M:%S  '"
alias-if-needed tmuxconf   "vim $HOME/.tmux.conf"
alias-if-needed tree       "ls --tree"
alias-if-needed u          "cd ../"
alias-if-needed uu         "cd ../../"
alias-if-needed uuu        "cd ../../../"
alias-if-needed uuuu       "cd ../../../../"
alias-if-needed vim        "nvim"
alias-if-needed xsel       "xsel -b"


# --------------------------------------------------
# key binding
# --------------------------------------------------
function fish_user_key_bindings
  bind-if-available ''  'fzf_key_bindings'
  bind-if-available \co 'gitmoji_fish'
end


sleep 0.5
