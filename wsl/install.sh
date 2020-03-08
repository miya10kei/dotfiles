#!/bin/bash

#  __      __  _________.____
# /  \    /  \/   _____/|    |
# \   \/\/   /\_____  \ |    |
#  \        / /        \|    |___
#   \__/\  / /_______  /|_______ \
#        \/          \/         \/

function install_graalvm() {
  echo "======================="
  echo "--- Install GraalVM ---"
  echo "======================="

  GRAALVM_DIR="/usr/lib/graalvm"
  GRAALVM_VERSION="19.3.0.2"
  GRAALVM_JAVA_VERSION="11"
  GRAALVM_HOME="$GRAALVM_DIR/graalvm-ce-java$GRAALVM_JAVA_VERSION-$GRAALVM_VERSION"
  if [ ! -e $GRAALVM_DIR ]; then
    sudo mkdir -p $GRAALVM_DIR
  fi
  if [ ! -e $GRAALVM_HOME ]; then
    sudo curl -sL "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-java$GRAALVM_JAVA_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz" --output /tmp/graalvm.tar.gz
    sudo tar -xf /tmp/graalvm.tar.gz -C $GRAALVM_DIR
    sudo chmod -R 755 $GRAALVM_DIR
    export GRAALVM_HOME="$GRAALVM_HOME"
    sudo $GRAALVM_HOME/bin/gu install native-iamge
    sudo rm -rf /tmp/graalvm.tar.gz
  fi
}

function install_nodejs() {
  echo "======================="
  echo "--- Install node.js ---"
  echo "======================="

  if [ -e $HOME/.nvm ]; then
    echo "node.js has already installed."
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install --lts
    nvm use node
    nvm alias default node
  fi
}

function install_npm_package() {
  echo "==========================="
  echo "--- Install npm package ---"
  echo "==========================="

  npm i -g \
    bash-language-server \
    dockerfile-language-server-nodejs \
    jay-repl
}

function install_ruby() {
  echo "===================="
  echo "--- Install ruby ---"
  echo "===================="

  if [ -e $HOME/.rbenv ]; then
    echo "ruby has already instlled."
  else
    git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    export PATH="$HOME/.rbenv/bin:$PATH"
    $HOME/.rbenv/bin/rbenv init
    RUBY_VERSION=`rbenv install -l | egrep "^\w+\.\w+\.\w+$" | tail -1`
    rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
    gem install bundler
    gem env home
  fi
}

function install_tmux_plugin() {
  echo "==========================="
  echo "--- Install tmux plugin ---"
  echo "==========================="

  if [ -e $HOME/.tmux ]; then
    echo "tmux plugin has already instlled."
  else
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    sudo sed -i -e "/^ENABLED/{s/false/true/}" /etc/default/sysstat
  fi
}



function main() {
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get -y update
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y \
    autoconf \
    bison \
    build-essential \
    gradle \
    jq \
    libffi-dev \
    libgdbm5 \
    libgdbm-dev \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    maven \
    neovim \
    sysstat \
    tmux \
    tree \
    zlib1g-dev
  sudo apt-get -y autoremove

  install_graalvm
  install_nodejs
  install_npm_package
  install_ruby
  install_tmux_plugin
}

main
