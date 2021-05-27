#!/usr/bin/env bash

if [ -n "$DOCKER_GID" ] && [ -n "$REMOTE_USER" ]; then
  sudo groupadd -g  $DOCKER_GID docker
  sudo usermod  -aG docker $REMOTE_USER
fi

exec "$@"

