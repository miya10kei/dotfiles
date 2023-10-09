.PHONY: setup-nvim
setup-nvim: \
	install-plugins \
	install-mason-pkg

.PHONY: install-plugins
install-plugins:
	nvim --headless -c 'Lazy sync' -c 'qa'

.PHONY: install-mason-pkg
install-mason-pkg:
	nvim --headless -c 'MasonInstallNeeded' -c 'qa'
