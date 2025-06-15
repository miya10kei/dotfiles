function alias_if_exists() {
    key=$1
    alias_cmd=$2
    cmd=$3
    alternative_cmd=$4

    if [[ -z "$cmd" ]]; then
        alias $key="$alias_cmd"
    elif eval "type $cmd" > /dev/null 2>&1; then
        alias $key="$alias_cmd"
    elif [[ -n "$alternative_cmd" ]]; then
        alias $key="$alternative_cmd"
    fi
}

function _fzf_change_directory() {
  selected=$(eval $1 | fzf-tmux $FZF_TMUX_OPTS)
  if [ -n "$selected" ]; then
    base_dir=$(eval $2)
    cd "$base_dir/$selected"
  fi
}

function pysw(){
  selected=$(pyenv versions | grep -Ev '(\*|system)' | awk '{print $1}' | fzf)
  if [ -n "$selected" ]; then
    pyenv global $selected
  fi
}

function quit() {
    if builtin command -v gpgconf > /dev/null 2>&1; then
        gpgconf --kill gpg-agent
    fi
    exit
}

alias_if_exists 'cdc'       '_fzf_change_directory "ls -1D" "pwd"'
alias_if_exists 'cdf'       'cd $(find . -name "*" -type d | fzf)' 'fzf'
alias_if_exists 'cdg'       '_fzf_change_directory "ghq list" "ghq root"' 'ghq'
alias_if_exists 'cdot'      'cd $HOME/.dotfiles'
alias_if_exists 'cdr'       'cd -'
alias_if_exists 'cdw'       '_fzf_change_directory "ls -1D $HOME/dev/workspaces" "echo $HOME/dev/workspaces"'
alias_if_exists 'dk'        'docker'          'docker'
alias_if_exists 'g'         'git'             'git'
alias_if_exists 'll'        'exa -al --group-directories-first' 'exa' 'ls -la'
alias_if_exists 'ls'        'exa -a --group-directories-first'  'exa' 'ls -a'
alias_if_exists 'q'         'quit'
alias_if_exists 'rm'        'rm -i'
alias_if_exists 'rr'        'rm -ir'
alias_if_exists 'rrf'       'rm -fr'
alias_if_exists 'tf'        'terraform'
alias_if_exists 'u'         'cd ../'
alias_if_exists 'uu'        'cd ../../'
alias_if_exists 'uuu'       'cd ../../../'
alias_if_exists 'uuuu'      'cd ../../../../'
alias_if_exists 'v'         'nvim'            'nvim' 'vim'
alias_if_exists 'vim'       'nvim'            'nvim'
alias_if_exists 'pgcli'     'pgcli --auto-vertical-output' 'pgcli'
alias_if_exists 'pysw'      'pysw'
alias_if_exists 'epochtime' 'date +%s'
alias_if_exists 'dive-mine' 'ssh miya10kei@192.168.1.215'
