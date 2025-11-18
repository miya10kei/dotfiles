if builtin command -v gtr > /dev/null 2>&1; then

  function select_worktree() {
    worktree=$(gtr list --porcelain | grep -v "detached" | awk '{print $2}' | fzf)
    if [ -z "$worktree" ]; then
      return 1
    fi
    echo "$worktree"
  }

  function gtred() {
    worktree=$(select_worktree) || return
    gtr editor "$worktree"
  }

  function gtrai() {
    worktree=$(select_worktree) || return
    gtr ai "$worktree"
  }

  function gtrrm() {
    worktree=$(select_worktree) || return
    gtr rm "$worktree"
  }

elif builtin command -v ghq > /dev/null 2>&1; then

  ghq get git@github.com:coderabbitai/git-worktree-runner.git
  ln -fs "$(ghq root)/$(ghq list git-worktree-runner)/bin/git-gtr" "$HOME/.local/bin/git-gtr"
  ln -fs "$(ghq root)/$(ghq list git-worktree-runner)/bin/gtr" "$HOME/.local/bin/gtr"

fi
