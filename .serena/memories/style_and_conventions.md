# Style and Conventions

## General Code Style

### EditorConfig Settings
- **Charset**: UTF-8
- **Line endings**: LF
- **Indent**: 2 spaces (tabs for Makefile)
- **Max line length**: 120 characters
- **Final newline**: Yes
- **Trailing whitespace**: Trimmed (except Markdown)

### Markdown
- **Indent**: 4 spaces for lists
- Trailing whitespace preserved

## Lua (Neovim Configuration)

### LuaFormatter Settings
- **Column limit**: 120
- **Single quotes**: Preferred (double_quote_to_single_quote: true)
- **Table formatting**: Chop down (one element per line)
- **Extra separator at table end**: Yes

### Neovim Plugin Structure
- One file per plugin in `lua/plugins/`
- Use `---@type LazySpec` annotation
- Return table with plugin specification

### Formatting Tool
- **stylua** (via Mason)

## Python

### Formatter
- **ruff_organize_imports** + **ruff_format** (conform.nvim)

### Linter
- **ruff** (nvim-lint)

## JavaScript/TypeScript

### Formatter
- **prettier** (conform.nvim)

## Terraform

### Formatter
- **terraform_fmt** (conform.nvim)

### Linter
- **tfsec** (nvim-lint)

## YAML

### Formatter
- **yamlfmt** (conform.nvim)

## Markdown

### Formatter
- **markdownlint** (conform.nvim)

### Linter
- **markdownlint** (nvim-lint)

### Markdownlint Config (.markdownlintrc)
- List indent: 4 spaces

## GitHub Actions

### Linter
- **actionlint** (nvim-lint, triggered for `yaml.ghaction` filetype)

## Docker

### Linter
- **hadolint** (nvim-lint)

## Go

### Formatter
- **goimports** + **gofmt** (conform.nvim)

## Git Conventions

### Commit Messages
- Start with gitmoji (https://gitmoji.dev/)
- If branch is `feature/XXXX-1234`, include ticket number after gitmoji
- One logical change per commit

### Branch Naming
- Feature branches: `feature/XXXX-1234`
