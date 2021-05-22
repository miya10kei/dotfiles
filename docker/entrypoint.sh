#!/usr/bin/env bash

if [ -n "$REMOTE_UID" ] && [ -n "$REMOTE_GID" ] && [ -n "$REMOTE_USER" ] && [ -n "$REMOTE_GROUP_NAME" ]; then
  HOME_DIR=/home/${REMOTE_USER}

  groupadd -g $REMOTE_GID $REMOTE_GROUP_NAME
  useradd  -g $REMOTE_GID -o $REMOTE_USER -u $REMOTE_UID
  chown    -R $REMOTE_UID:$REMOTE_GID $HOME_DIR
  echo "$REMOTE_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
  chmod 440 /etc/sudoers

  if [ -n "$DOCKER_GID" ]; then
    groupadd -g  $DOCKER_GID docker
    usermod  -aG docker $REMOTE_USER

  fi

  if [ "${REMOTE_USER}" = "ansible" ]; then
    if [[ ! "$(cat $HOME_DIR/.ssh/authorized_keys)" =~ "$(cat $HOME_DIR/.ssh/id_rsa_ansible.pub)" ]]; then
      echo "contains"
      cat $HOME_DIR/.ssh/id_rsa_ansible.pub > $HOME_DIR/.ssh/authorized_keys
    fi
  fi

  echo "Starting with $REMOTE_USER(uid=$REMOTE_UID, gid=$REMOTE_GID)"
  exec /usr/sbin/gosu $REMOTE_USER "$@"
else
  exec "$@"
fi

