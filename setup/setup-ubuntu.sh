#!/bin/env bash

readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)

source $SCRIPT_DIR/setup-common.sh

function main() {
  installBasic
  installChrome
  installDocker
  installFish
  installGhq
  installHyper
  installIdea
  installJdk
  installLibinputGestures
  installNeovim

  config
  linkDotfiles
}

function installBasic() {
  sudo apt-get update \
    && sudo apt-get install -y \
                      apt-transport-https \
                      curl \
                      gdebi-core \
                      git \
                      gnome-tweak-tool \
                      jq \
                      mozc-utils-gui \
                      peco \
                      tlp \
                      tmux \
                      ufw
}

function installChrome() {
  local -r GPG_PATH_CHROME=/etc/apt/trusted.gpg
  local -r SOURCE_LIST_CHROME=/etc/apt/sources.list.d/google-chrome.list

  if ! [ -e $GPG_PATH_CHROME ]; then
    curl -s https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  fi

  if ! [ -e $SOURCE_LIST_CHROME ]; then
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' \
      | sudo tee $SOURCE_LIST_CHROME
  fi

  sudo apt-get update \
    && sudo apt-get install -y google-chrome-stable
}

function installDocker() {
  sudo apt-get update \
    && sudo apt-get install -y ca-certificates gnupg lsb-release

  local -r URL_DOCKER=https://download.docker.com/linux/ubuntu
  local -r GPG_PATH_DOCKER=/usr/share/keyrings/docker-archive-keyring.gpg
  local -r SOURCE_LIST_DOCKER=/etc/apt/sources.list.d/docker.list

  if ! [ -e $SOURCE_LIST_DOCKER ]; then
    curl -fsSL $URL_DOCKER/gpg | sudo gpg --dearmor -o $GPG_PATH_DOCKER
    echo "deb [arch=amd64 signed-by=$GPG_PATH_DOCKER] $URL_DOCKER $(lsb_release -cs) stable" \
      | sudo tee $SOURCE_LIST_DOCKER > /dev/null
  fi

  sudo apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo gpasswd -a $USER docker
}

function installFish() {
  if ! [ -e /etc/apt/sources.list.d/fish-shell-ubuntu-release-3-focal.list ]; then
    sudo apt-add-repository -ny ppa:fish-shell/release-3
  fi

  sudo apt-get update \
    && sudo apt-get install -y fish
}

function installGhq() {
  if ! [ -e /usr/local/bin/ghq ]; then
    pushd $HOME/Downloads
    curl -sLO https://github.com/x-motemen/ghq/releases/download/v1.1.7/ghq_linux_amd64.zip
    unzip ghq_linux_amd64.zip
    sudo mv ghq_linux_amd64/ghq /usr/local/bin/ && sudo chown root:root /usr/local/bin/ghq
    rm -rf ghq_linux_amd64*
    popd
  fi
}

function installHyper() {
  if ! type hyper > /dev/null 2>&1; then
    curl -L -o $HOME/Downloads/hyper.deb https://releases.hyper.is/download/deb
    sudo gdeb -n $HOME/Downloads/hyper.deb
    rm -rf $HOME/Downloads/hyper.deb
  fi
}

function installIdea() {
  sudo snap install intellij-idea-ultimate --classic
}

function installJdk() {
  local -r URL_DOCKER=https://download.docker.com/linux/ubuntu
  local -r SOURCE_LIST_BELLSOFT=/etc/apt/sources.list.d/bellsoft.list

  if ! [ -e $SOURCE_LIST_BELLSOFT ]; then
    curl -s https://download.bell-sw.com/pki/GPG-KEY-bellsoft | sudo apt-key add -
    echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" | sudo tee $SOURCE_LIST_BELLSOFT
  fi

  sudo apt-get update \
    && sudo apt-get install -y bellsoft-java11 bellsoft-java16
}

function installLibinputGestures() {
  if ! [ -e /usr/bin/libinput-gestures ]; then
    sudo gpasswd -a $USER input
    sudo apt-get update \
      && sudo apt-get install -y wmctrl xdotool libinput-tools
    pushd $HOME/Downloads
    git clone https://github.com/bulletmark/libinput-gestures.git
    pushd libinput-gestures
    sudo make install
    popd && popd
    rm -rf $HOME/Downloads/libinput-gestures
    libinput-gestures-setup autostart
  fi
}

function installNeovim() {
  if ! [ -e /etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-focal.list ]; then
    sudo add-apt-repository -ny ppa:neovim-ppa/stable
  fi

  sudo apt-get update \
    && sudo apt-get install -y neovim nodejs npm
}

function config() {
  # mkdir
  mkdir -p $HOME/dev/private $HOME/.local/share/fonts
  # font
  if ! [ -e /$HOME/.local/share/fonts/Source\ Code\ Pro\ for\ Powerline.otf ]; then
    pushd $HOME/.local/share/fonts
    curl -s -o 'Source Code Pro for Powerline.otf' https://raw.githubusercontent.com/powerline/fonts/master/SourceCodePro/Source%20Code%20Pro%20for%20Powerline.otf
    fc-cache -f $HOME/.local/share/fonts
    popd
  fi
  # caps -> ctrl
  cat /etc/default/keyboard | sed s/XKBOPTIONS=\"\"/XKBOPTIONS=\"ctrl:nocaps\"/ | sudo tee /etc/default/keyboard > /dev/null
  # default shell
  sudo chsh -s /usr/bin/fish
  # generate ssh key
  if ! [ -e $HOME/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "miya10kei@gmail.com"
  fi
  # enable & start tlp
  sudo systemctl enable tlp.service
  sudo systemctl start tlp.service
  # ufw
  sudo ufw enable
  # tpm
  if ! [ -e $HOME/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
  fi
  # emoji
  curl -s -o $HOME/.emoji.list https://raw.githubusercontent.com/miya10kei/emoji-dict/main/dist/emoji.list
}

main

