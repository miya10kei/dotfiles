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

alias_if_exists 'cdg'  'cd $(ghq list --full-path | fzf)' 'ghq'
alias_if_exists 'cdot' 'cd $HOME/.dotfiles'
alias_if_exists 'cdr'  'cd -'
alias_if_exists 'cdw'  'cd $HOME/dev/workspaces'
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
