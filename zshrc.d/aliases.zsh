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
  selected=$(eval $1 | fzf)
  if [ -n "$selected" ]; then
    base_dir=$(eval $2)
    cd "$base_dir/$selected"
  fi
}

alias_if_exists 'cdc'  '_fzf_change_directory "ls -1D" "pwd"'
alias_if_exists 'cdg'  '_fzf_change_directory "ghq list" "ghq root"' 'ghq'
alias_if_exists 'cdot' 'cd $HOME/.dotfiles'
alias_if_exists 'cdr'  'cd -'
alias_if_exists 'cdw'  '_fzf_change_directory "ls -1D $HOME/dev/workspaces" "echo $HOME/dev/workspaces"'
alias_if_exists 'dk'   'docker'          'docker'
alias_if_exists 'g'    'git'             'git'
alias_if_exists 'll'   'exa -al'         'exa' 'ls -la'
alias_if_exists 'ls'   'exa -a'          'exa' 'ls -a'
alias_if_exists 'q'    'exit'
alias_if_exists 'rm'   'rm -i'
alias_if_exists 'rr'   'rm -ir'
alias_if_exists 'rrf'  'rm -fr'
alias_if_exists 'u'    'cd ../'
alias_if_exists 'uu'   'cd ../../'
alias_if_exists 'uuu'  'cd ../../../'
alias_if_exists 'uuuu' 'cd ../../../../'
alias_if_exists 'v'    'nvim'            'nvim' 'vim'
alias_if_exists 'vim'  'nvim'            'nvim'
