#!/usr/bin/env bash
set -euo pipefail

eval "$(mise activate bash)"

abort() {
  printf '%s\n' "$1" >&2
  read -rsn1 -p "Press any key to close..."
  exit 1
}

stderr_file=$(mktemp)
trap 'rm -f "$stderr_file"' EXIT

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
  worktree_json=$(herdr worktree open --cwd "$repo" --path "$existing_path" --focus --json 2>"$stderr_file") \
    || abort "worktree open failed: $(jq -r '.error.message // .' "$stderr_file" 2>/dev/null || cat "$stderr_file")"
else
  worktree_json=$(herdr worktree create --cwd "$repo" --branch "$branch" --path "$repo/.claude/worktrees/$branch" --focus --json 2>"$stderr_file") \
    || abort "worktree create failed: $(jq -r '.error.message // .' "$stderr_file" 2>/dev/null || cat "$stderr_file")"
fi
pane_id=$(echo "$worktree_json" | jq -r '.result.root_pane.pane_id')
herdr pane run "$pane_id" "claude"
