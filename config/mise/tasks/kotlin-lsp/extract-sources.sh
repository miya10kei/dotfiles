#!/usr/bin/env bash
#MISE description="kotlin-lspの依存ソースを~/.local/share/kotlin-lsp/sources/に抽出"
set -euo pipefail

# extract-sources.py は cargo crate の contrib/ に同梱されているため、
# mise が把握する現行バージョンに対応する registry ソースから直接実行する。
version=$(basename "$(mise where cargo:kotlin-lsp)")

shopt -s nullglob
candidates=( "${HOME}"/.cargo/registry/src/*/kotlin-lsp-"${version}"/contrib/extract-sources.py )
if (( ${#candidates[@]} == 0 )); then
  echo "extract-sources.py not found for kotlin-lsp ${version} under ~/.cargo/registry/src/." >&2
  echo "Hint: run 'mise install --force cargo:kotlin-lsp' to repopulate the registry source." >&2
  exit 1
fi

python3 "${candidates[0]}" --output "${HOME}/.local/share/kotlin-lsp/sources"
