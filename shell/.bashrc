#     ____  ___   _____ __  ______  ______
#    / __ )/   | / ___// / / / __ \/ ____/
#   / __  / /| | \__ \/ /_/ / /_/ / /
#  / /_/ / ___ |___/ / __  / _, _/ /___
# /_____/_/  |_/____/_/ /_/_/ |_|\____/

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

main() {
  # path
  export PATH=$HOME/bin:"$PATH"
  export NVIM_HOME=$HOME/.config/nvim

  # mailcheck
  unset MAILCHECK

  # editor
  export EDITOR=nvim

  # pager
  export PAGER=less

  # less
  export LESS='-I -R -M -W -x2'
  export LESSCHARSET='utf-8'

  # less man
  export LESS_TERMCAP_mb=$'\E[01;31m'
  export LESS_TERMCAP_md=$'\E[01;31m'
  export LESS_TERMCAP_me=$'\E[0m'
  export LESS_TERMCAP_se=$'\E[0m'
  export LESS_TERMCAP_so=$'\E[01;44;33m'
  export LESS_TERMCAP_ue=$'\E[0m'
  export LESS_TERMCAP_us=$'\E[01;32m'

  # history settings
  export HISTCONTROL=ignoreboth:erasedups
  export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:  "
  export HISTSIZE=50000
  export HISTFILESIZE=50000

  bashrc_shopt
  bashrc_aliases
  bashrc_pkg_set
  bashrc_load_module
  bashrc_ps1
  print_hello_art
}

# shopt
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
bashrc_shopt() {
  # If set, minor errors in the spelling of a directory component in a cd command will be corrected.
  # The errors checked for are transposed characters, a missing character, and a character too many.
  # If a correction is found, the corrected path is printed, and the command proceeds.
  # This option is only used by interactive shells.
  shopt -s cdspell
  # If set, Bash checks the window size after each external (non-builtin) command and,
  # if necessary, updates the values of LINES and COLUMNS. This option is enabled by default.
  shopt -s checkwinsize
  # If set, Bash attempts to save all lines of a multiple-line command in the same history entry.
  # This allows easy re-editing of multi-line commands. This option is enabled by default,
  # but only has an effect if command history is enabled (see Bash History Facilities).
  shopt -s cmdhist
  # If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories.
  # If the pattern is followed by a ‘/’, only directories and subdirectories match.
  shopt -s globstar
  # If set, the history list is appended to the file named by the value of the HISTFILE variable
  # when the shell exits, rather than overwriting the file.
  shopt -s histappend
  # If set, and Readline is being used, Bash will not attempt to search the PATH for possible completions
  # when completion is attempted on an empty line.
  shopt -s no_empty_cmd_completion
  # If set, Bash matches filenames in a case-insensitive fashion when performing filename expansion.
  shopt -s nocaseglob
}

bashrc_aliases() {
  if [ "$(uname)" = 'Darwin' ]; then
    export LSCOLORS=gxfxcxdxbxegedabagacad
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
  alias ll='ls -lhv'
  alias lla='ls -lhAv'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
  alias h='history 30'
  alias g='git'
  alias v='vim'
  alias r='ruby'
  alias jp='ruby $HOME/.bin/json_parser.rb'
  alias url='ruby ~/.bin/url_encoder.rb'
  alias d='docker'
  alias dcon='docker container'
  alias dexec='docker container exec'
  alias drun='docker container run'
  alias dbuild='docker image build'
  alias vim='nvim'
  [ -e $HOME/.bash_aliases ] && source $HOME/.bash_aliases
}

bashrc_pkg_set() {
  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash
  # gcc
  export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
  # nvm
  if [ -e $HOME/.nvm ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  fi
  # rbenv
  if [ -e $HOME/.rbenv ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  # yarn
  if type yarn > /dev/null 2>&1; then
    export path="$path:`yarn global bin`"
  fi
  # java
  if [ -e ${HOME}/.java_version ]; then
    export PATH="$JAVA_HOME/bin:$PATH"
    source ${HOME}/.java_version
  fi
}

bashrc_load_module() {
  for module in ~/.modules/*.*; do
    source $module
  done
}

bashrc_ps1() {
  [[ $TERM =~ xterm-color|.*-256color ]] && color_prompt=yes

  GIT_PS1_SHOWCOLORHINTS=true
  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWSTASHSTATE=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  GIT_PS1_SHOWUPSTREAM="auto"

  if [ "$color_prompt" = yes ]; then
    PS1='\[\e[00m\]╭─○ '
    PS1=$PS1'\[\e[1;32m\]${USER}\[\e[00m\]@\[\e[1;36m\]\h'
    PS1=$PS1'\[\e[00m\](\[\e[1;35m\]\D{%Y/%m/%d} \t\[\e[00m\])'
    PS1=$PS1': '
    PS1=$PS1'\[\e[1;34m\]\w'
    PS1=$PS1'\[\e[00m\] (\[\e[1;33m\]$(__git_ps1 "%s")\[\e[00m\])'
    PS1=$PS1'\[\e[00m\]\n╰─○ '
  else
    PS1='╭─○ ${USER}@\h(\D{%Y/%m/%d} \t): \w $(__git_ps1 (%s)")\n╰─○ '
  fi
}

print_hello_art() {
  if [ -n $TMUX ]; then
    tmux_pane_num=`tmux list-pane 2>/dev/null | wc -l`
    if [ $tmux_pane_num -eq 1 ]; then
      cat $HOME/.hello_art.txt
    fi
  fi
}

main

echo '.bashrc loaded.'
