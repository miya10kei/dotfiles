#!/usr/bin/env bash
#MISE description="kmp-lspの依存ソースを~/.local/share/kmp-lsp/sources/に抽出"
set -euo pipefail

kmp-lsp extract-sources --output "${HOME}/.local/share/kmp-lsp/sources"
