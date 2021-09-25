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
set -g theme_color_scheme               gruvbox
set -g theme_date_format                "+%Y-%m-%d %H:%M:%S(%a)"
set -g theme_date_timezone              Asia/Tokyo
set -g theme_display_docker_machine     yes
set -g theme_display_git_default_branch yes
set -g theme_display_user               yes
set -g theme_nerd_fonts                 yes
set -g theme_newline_cursor             yes
set -g theme_newline_prompt             \uf739' '
set -g theme_powerline_fonts            no
set -g theme_show_exit_status           yes

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
# common
# --------------------------------------------------
addPath $HOME/.local/bin


# --------------------------------------------------
# Homebrew
# --------------------------------------------------
switch $OS
  case "Darwin"
    # nop
  case "Linux"
    addPath /home/linuxbrew/.linuxbrew/bin
    addPath /home/linuxbrew/.linuxbrew/sbin
end


# --------------------------------------------------
# language configuration
# --------------------------------------------------
# java
# --------------------------------------------------
if test -e $HOME/.sdkman
  set -x JAVA_HOME $HOME/.sdkman/candidates/java/current

  for candidate in $HOME/.sdkman/candidates/* ;
    addPath $candidate/current/bin
  end

  if type -q __sdk_auto_env
    function sdk_auto_env --on-variable PWD
      __sdk_auto_env
    end
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
# nim
# --------------------------------------------------
addPath $HOME/.nimble/bin
# --------------------------------------------------
# nodejs
# --------------------------------------------------
if type -q node; and type -q npm; and type -q yarn
  addPath (yarn global bin)
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
  set -x NVIM_HOME $HOME/.config/nvim
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
      set -a cmds "pushd $HOME/.config/coc/extensions && ncu -u && yarn upgrade && popd"
      #yarn install --global-style --ignore-scripts  --no-bin-links --no-lockfile --production
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
alias-if-needed sed        "gsed" "gsed"
alias-if-needed thistory   "history --show-time='%Y-%m-%d %H:%M:%S  '"
alias-if-needed tmuxconf   "vim $HOME/.tmux.conf"
alias-if-needed tree       "ls --tree"
alias-if-needed u          "cd ../"
alias-if-needed uu         "cd ../../"
alias-if-needed uuu        "cd ../../../"
alias-if-needed uuuu       "cd ../../../../"
alias-if-needed vim        "nvim"
alias-if-needed vi         "vim"
alias-if-needed v          "vi"
alias-if-needed xsel       "xsel -b"


# --------------------------------------------------
# key binding
# --------------------------------------------------
function fish_user_key_bindings
  bind-if-available ''  'fzf_key_bindings'
  bind-if-available \co 'gitmoji_fish'
end


sleep 0.5
