#!/usr/bin/env bash
set -euo pipefail

repo_short=$({ echo "dotfiles"; ghq list; } | fzf --prompt="repo> ")
[ -z "$repo_short" ] && exit 0
if [ "$repo_short" = "dotfiles" ]; then
  repo="$HOME/.dotfiles"
else
  repo="$(ghq root)/$repo_short"
fi

read -rp "worktree branch name: " branch
[ -z "$branch" ] && exit 0

herdr worktree create --cwd "$repo" --branch "$branch" --focus
