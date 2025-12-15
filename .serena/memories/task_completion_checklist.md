# Task Completion Checklist

When completing a task in this repository, verify the following:

## Code Quality Checks

1. **No character corruption (mojibake)**
   - Verify UTF-8 encoding is maintained

2. **Code-comment consistency**
   - Comments accurately describe the code
   - Remove outdated comments

3. **Naming consistency**
   - Class/function/variable names match their behavior
   - Names accurately express the processing content

4. **LSP Diagnostics**
   - Check for errors/warnings from language servers
   - Resolve any issues before completing

## Formatting & Linting

### Lua Files (Neovim config)
```bash
stylua <file>             # Format
# Or in Neovim: <Leader>f
```

### Python Files
```bash
uv run ruff check <file>  # Lint
uv run ruff format <file> # Format
```

### Markdown Files
```bash
# Via Neovim: <Leader>f (uses markdownlint)
```

### General
- Use `<Leader>f` in Neovim to format current buffer
- Format-on-save is enabled by default (toggle with `<Leader>t`)

## Documentation

- Update README.md if adding new features/tools
- Update CLAUDE.md if adding new patterns/conventions
- Ensure documentation matches implementation

## Git

### Before Commit
- Check only intended files are staged
- Verify no sensitive data (credentials, keys)

### Commit Message
- Use gitmoji prefix (https://gitmoji.dev/)
- Include ticket number if branch is `feature/XXXX-1234`
- Keep message concise and descriptive

## Neovim-Specific

### Adding New Plugin
1. Create file in `config/nvim/lua/plugins/`
2. Add keymaps to `lua/config/keymaps.lua` if needed
3. Run `:Lazy sync` to install

### Adding Mason Package
1. Add to `vim.g.mason_packages` in `lua/plugins/mason.lua`
2. Run `:MasonInstallNeeded` to install

## Adding New CLI Tool

1. Add version variable to `Makefile.d/bin.mk`
2. Add install target
3. Add to `install-bins` dependencies
4. Add to `setup4d` if needed for Docker auto-setup
