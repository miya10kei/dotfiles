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

workspace_id="${HERDR_ACTIVE_WORKSPACE_ID:?HERDR_ACTIVE_WORKSPACE_ID is not set}"
worktree_json=$(herdr workspace get "$workspace_id" | jq '.result.workspace.worktree')
[ "$(echo "$worktree_json" | jq -r '.is_linked_worktree // false')" = "true" ] \
  || abort "workspace $workspace_id is not a linked worktree"

checkout_path=$(echo "$worktree_json" | jq -r '.checkout_path')
repo_root=$(echo "$worktree_json" | jq -r '.repo_root')
branch=$(git -C "$checkout_path" branch --show-current)
cd "$repo_root"

close_only="workspaceだけ閉じる"
remove_worktree="worktreeを削除"
remove_worktree_and_branch="worktreeとbranchを削除"
action=$(gum choose --header "${branch:-(detached)} ($checkout_path)" \
  "$close_only" "$remove_worktree" "$remove_worktree_and_branch") || exit 0

if [ "$action" != "$close_only" ]; then
  force_option=()
  if [ -n "$(git -C "$checkout_path" status --porcelain)" ]; then
    gum confirm "未コミットの変更があります。--forceで削除しますか？" || exit 0
    force_option=(--force)
  fi
  git worktree remove "${force_option[@]}" "$checkout_path" 2>"$stderr_file" \
    || abort "worktree remove failed: $(cat "$stderr_file")"
fi

if [ "$action" = "$remove_worktree_and_branch" ] && [ -n "$branch" ]; then
  if ! git branch -d "$branch" 2>"$stderr_file"; then
    if gum confirm "branch $branch は未マージです。-Dで削除しますか？"; then
      git branch -D "$branch" 2>"$stderr_file" || abort "branch delete failed: $(cat "$stderr_file")"
    fi
  fi
fi

# ポップアップが閉じられても後続処理が失われないよう、workspaceのcloseは最後に行う
herdr workspace close "$workspace_id" 2>"$stderr_file" \
  || abort "workspace close failed: $(jq -r '.error.message // .' "$stderr_file" 2>/dev/null || cat "$stderr_file")"
