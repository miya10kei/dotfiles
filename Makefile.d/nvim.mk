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
	nvim --headless -c 'MasonInstallNeeded' -c 'qa'

.PHONY: install-treesitter-pkg
install-treesitter-pkg:
	nvim --headless -c 'TreeSitterInstall' -c 'qa'
