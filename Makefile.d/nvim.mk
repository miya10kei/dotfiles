MASON_PKG := \
			 bash-language-server \
			 docker-compose-language-service \
			 dockerfile-language-server \
			 flake8 \
			 goimports \
			 gopls \
			 haskell-language-server \
			 html-lsp \
			 json-lsp \
			 lua-language-server \
			 pyright \
			 terraform-ls \
			 typescript-language-server \
			 yaml-language-server

.PHONY: setup-nvim
setup-nvim: \
	install-plugins \
	install-mason-pkg

.PHONY: install-plugins
install-plugins:
	nvim --headless -c 'Lazy sync' -c 'qa'

.PHONY: install-mason-pkg
install-mason-pkg:
	nvim --headless -c 'MasonInstall $(MASON_PKG)' -c 'qa'
