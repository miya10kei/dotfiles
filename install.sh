#!/usr/bin/env bash

main() {
  if [ -z `which git` ]; then;
    echo "Please install git."
    return 0
  fi

  cd ~
  git clone https://github.com/miya10kei/dotfiles.git
}

create_symlink() {
  cd ~/dotfiles
  for f in `find . -maxdepth 1 -type f`; do
    ln -svfn ~/dotfiles/`basesname ${f}` ~/"${f}
  done
}

main
