#!/usr/bin/env bash

readonly REPOS_NAME='dotfiles'
readonly REPOS_PATH=$HOME/$REPOS_NAME

function main() {
  if ! type git > /dev/null 2>&1; then
    echo "Please install git."
    return 0
  fi

  clone_repos
  create_symlink
}

function clone_repos() {
  if [ -e $REPOS_PATH ]; then
    (cd $REPOS_PATH && git pull > /dev/null)
  else
    git clone https://github.com/miya10kei/dotfiles.git $REPOS_PATH
  fi
}

function create_symlink() {
  for f in `find $REPOS_PATH -maxdepth 1 -not \( -name '.git' -o -name 'install.sh' -o -name $REPOS_NAME \)`; do
    fname=`basename $f`
    ln -svfn $REPOS_PATH/$fname $HOME/$fname
  done
}

main
