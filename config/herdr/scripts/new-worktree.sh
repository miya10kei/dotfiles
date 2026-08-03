#!/usr/bin/env bash
set -euo pipefail

repo_short=$(ghq list | fzf --prompt="repo> ")
[ -z "$repo_short" ] && exit 0
repo="$(ghq root)/$repo_short"

read -rp "worktree branch name: " branch
[ -z "$branch" ] && exit 0

herdr worktree create --cwd "$repo" --branch "$branch" --focus
