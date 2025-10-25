.PHONY: setup-nvim
setup-nvim: \
	install-plugins \
	install-mason-pkg \
	install-treesitter-pkg

.PHONY: install-plugins
install-plugins:
	nvim --headless -c 'Lazy sync' -c 'qa'

.PHONY: install-mason-pkg
install-mason-pkg:
	nvim --headless -c 'lua require("lazy").load({plugins={"nvim-lspconfig"}})' -c 'MasonInstallNeeded' -c 'qa'

.PHONY: install-treesitter-pkg
install-treesitter-pkg:
	nvim --headless -c 'lua require("lazy").load({plugins={"nvim-treesitter"}})' -c 'TSUpdateSync' -c 'qa'
