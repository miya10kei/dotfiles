#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
if [ "${ARCH}" = "x86_64" ]; then
  DL_ARCH="64bit"
else
  DL_ARCH="arm64"
fi

INSTALL_ROOT="${HOME}/.local/share/sessionmanagerplugin"
BIN_DIR="${HOME}/.local/bin"

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

curl -fsLS -o "${TMPDIR}/session-manager-plugin.deb" \
  "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${DL_ARCH}/session-manager-plugin.deb"

rm -rf "${INSTALL_ROOT}"
mkdir -p "${INSTALL_ROOT}" "${BIN_DIR}"
dpkg-deb -x "${TMPDIR}/session-manager-plugin.deb" "${INSTALL_ROOT}"

ln -sf "${INSTALL_ROOT}/usr/local/sessionmanagerplugin/bin/session-manager-plugin" \
  "${BIN_DIR}/session-manager-plugin"
