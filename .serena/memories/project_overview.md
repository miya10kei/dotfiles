# Project Overview

## Purpose
Personal dotfiles repository for managing development environment configuration files and setup scripts. Primarily contains configurations for Zsh, Neovim, tmux, Git, Claude, and other development tools.

## Tech Stack
- **Shell**: Zsh with Sheldon plugin manager
- **Editor**: Neovim (Lua-based configuration with lazy.nvim)
- **Terminal Multiplexer**: tmux
- **Container**: Docker (Ubuntu 24.04 base)
- **Languages in configs**: Lua (Neovim), Zsh shell scripts, Makefile

## Directory Structure

```
.dotfiles/
├── Makefile              # Main makefile
├── Makefile.d/           # Makefile modules
│   ├── deploy.mk         # Symlink deployment targets
│   ├── bin.mk            # CLI tool installation (versioned)
│   ├── nvim.mk           # Neovim tasks
│   ├── mac.mk            # macOS specific tasks
│   └── ...
├── config/               # Application configs
│   ├── nvim/             # Neovim config (Lua)
│   │   ├── lua/config/   # Core settings (keymaps, options, etc.)
│   │   ├── lua/plugins/  # Plugin configs (one file per plugin)
│   │   └── ftplugin/     # Filetype-specific settings
│   ├── sheldon/          # Zsh plugin manager
│   └── gh/               # GitHub CLI
├── claude/               # Claude Code configuration
│   ├── settings.json     # Claude settings
│   ├── CLAUDE.md         # Global instructions
│   └── commands/         # Custom slash commands
├── zshrc.d/              # Zsh config modules
│   ├── aliases.zsh
│   ├── aws.zsh
│   ├── docker.zsh
│   └── fzf.zsh
├── data-volume/          # Persistent data (not in git)
└── *.{zshrc,tmux.conf,...}  # Dotfiles
```

## Deployment Mechanism
Makefile `deploy-*` targets create **symbolic links** from dotfiles directory to `$HOME`. This enables:
1. Immediate reflection of changes
2. Easy version control
3. Simple synchronization across machines

## Docker Development Environment
- Base: Ubuntu 24.04
- Multi-architecture support (x86_64/aarch64)
- Languages: Python, Node.js, Go, Rust, Lua, Haskell, etc.
- Auto-setup via `make setup4d` when `.zshrc` detects Docker environment
