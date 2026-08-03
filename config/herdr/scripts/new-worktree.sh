#!/usr/bin/env bash
set -euo pipefail

eval "$(mise activate bash)"

repo_short=$({ echo "dotfiles"; ghq list | sed 's#^github.com/##'; } | fzf --prompt="repo> ")
[ -z "$repo_short" ] && exit 0
if [ "$repo_short" = "dotfiles" ]; then
  repo="$HOME/.dotfiles"
else
  repo="$(ghq root)/github.com/$repo_short"
fi

branch=$(gum input --placeholder "worktree branch name" --prompt "branch> ")
[ -z "$branch" ] && exit 0

herdr worktree create --cwd "$repo" --branch "$branch" --focus
