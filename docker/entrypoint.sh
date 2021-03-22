#!/usr/bin/env bash

NEW_UID=${REMOTE_UID}
NEW_GID=${REMOTE_GID}
NEW_USER=${REMOTE_USER}

if [ -n "${NEW_UID}" ] && [ -n "${NEW_GID}" ] && [ -n "${NEW_USER}" ]; then
  HOME_DIR=/home/${NEW_USER}

  useradd -u ${NEW_UID} -o ${NEW_USER}
  groupmod -g ${NEW_GID} ${NEW_USER}
  chown -R ${NEW_UID}:${NEW_GID} "$HOME_DIR"
  echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
  chmod 440 /etc/sudoers

  if [ "${NEW_USER}" = "ansible" ]; then
    # shellcheck disable=SC2076
    if [[ ! "$(cat $HOME_DIR/.ssh/authorized_keys)" =~ "$(cat $HOME_DIR/.ssh/id_rsa_ansible.pub)" ]]; then
      echo "contains"
      cat $HOME_DIR/.ssh/id_rsa_ansible.pub > $HOME_DIR/.ssh/authorized_keys
    fi
  fi

  echo "Starting with ${NEW_USER}(uid=${NEW_UID}, gid=${NEW_GID})"
  exec /usr/sbin/gosu ${NEW_USER} "$@"
else
  exec "$@"
fi
