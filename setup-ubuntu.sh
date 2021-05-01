#!/bin/env bash


function main() {
  installDocker
  installIdea
}

function installDocker() {
  sudo apt-get update \
    && sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

  local -r URL_DOCKER=https://download.docker.com/linux/ubuntu
  local -r GPG_PATH_DOCKER=/usr/share/keyrings/docker-archive-keyring.gpg
  local -r SOURCE_LIST_DOCKER=/etc/apt/sources.list.d/docker.list

  if ! [ -e $GPG_PATH_DOCKER ]; then
    curl -fsSL $URL_DOCKER/gpg | sudo gpg --dearmor -o $GPG_PATH_DOCKER
  fi

  if ! [ -e $SOURCE_LIST_DOCKER ]; then
    echo "deb [arch=amd64 signed-by=$GPG_PATH_DOCKER] $URL_DOCKER $(lsb_release -cs) stable" \
      | sudo tee $SOURCE_LIST_DOCKER > /dev/null
  fi

  sudo apt-get update \
    && sudo apt-get install docker-ce docker-ce-cli containerd.io
}

function installIdea() {
  sudo snap install intellij-idea-ultimate --classic
}

main

