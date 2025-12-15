# Suggested Commands

## Setup Commands

### Docker Development Environment
```bash
# Build Docker dev environment
make build-dev-env

# Deploy dotfiles (Docker environment)
make setup4d

# Install binary tools
make install4d
```

### Individual Deployment
```bash
make deploy-nvim          # Neovim config
make deploy-git           # Git config
make deploy-claude        # Claude config
make deploy-zsh           # Zsh config
make deploy-tmux          # tmux config
make deploy-sheldon       # Sheldon plugin manager
make deploy-aws           # AWS CLI config
make deploy-gh            # GitHub CLI config
```

## Neovim Commands

### Mason Package Management
```vim
:MasonInstallNeeded       " Install all defined packages
:MasonInstall <pkg>       " Install specific package
:Mason                    " Open Mason UI
```

### Formatting (conform.nvim)
```vim
<Leader>f                 " Format buffer
<Leader>t                 " Toggle format on save
:ConformInfo              " Show formatter info
```

### Linting (nvim-lint)
Linting runs automatically on:
- BufEnter
- BufWritePost
- InsertLeave

## CLI Tools (managed in bin.mk)

### Search & Navigation
- `fzf` - Fuzzy finder
- `rg` (ripgrep) - Fast grep
- `fd` - Fast find
- `zoxide` - Smart cd

### Git Tools
- `gh` - GitHub CLI
- `ghq` - Repository management
- `delta` - Git diff viewer

### Utilities
- `bat` - Better cat
- `jq` / `yq` / `xq` - JSON/YAML/XML processors
- `exa` - Better ls
- `procs` - Better ps
- `duf` - Disk usage

### AWS Tools
- `aws-cli` - AWS CLI v2
- `aws-vault` - AWS credential management
- `sam` - SAM CLI (via pyenv)

## System Utilities (Linux)
```bash
ls, cd, grep, find        # Standard Unix commands
git                       # Version control
docker                    # Container management
```

## Makefile Utility Targets
```bash
make delete-nvimrc        # Remove Neovim config
```
