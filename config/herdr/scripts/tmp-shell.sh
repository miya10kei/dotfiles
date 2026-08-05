#!/usr/bin/env bash
set -euo pipefail

cd "${HERDR_ACTIVE_PANE_CWD:-$HOME}"
exec "${SHELL:-bash}"
