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

worktree_list_json=$(herdr worktree list --cwd "$repo" --json)
existing_branches=$(echo "$worktree_list_json" | jq -r '.result.worktrees[] | select(.is_linked_worktree) | .branch')

branch=$({ [ -n "$existing_branches" ] && printf '%s\n' "$existing_branches"; true; } \
  | gum filter --no-strict --placeholder "worktree branch name" --prompt "branch> ")
[ -z "$branch" ] && exit 0

existing_path=$(echo "$worktree_list_json" \
  | jq -r --arg branch "$branch" '.result.worktrees[] | select(.branch == $branch) | .path' | head -n1)

if [ -n "$existing_path" ]; then
  worktree_json=$(herdr worktree open --cwd "$repo" --path "$existing_path" --focus --json)
else
  worktree_json=$(herdr worktree create --cwd "$repo" --branch "$branch" --path "$repo/.claude/worktrees/$branch" --focus --json)
fi
pane_id=$(echo "$worktree_json" | jq -r '.result.root_pane.pane_id')
herdr pane run "$pane_id" "claude"
