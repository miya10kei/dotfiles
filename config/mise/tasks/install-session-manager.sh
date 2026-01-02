#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
if [ "${ARCH}" = "x86_64" ]; then
  DL_ARCH="64bit"
else
  DL_ARCH="arm64"
fi

mkdir -p /tmp/sessionmanagerplugin
curl -fsLS -o /tmp/sessionmanagerplugin/session-manager-plugin.deb \
  "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${DL_ARCH}/session-manager-plugin.deb"
sudo dpkg --install /tmp/sessionmanagerplugin/session-manager-plugin.deb
rm -rf /tmp/sessionmanagerplugin
