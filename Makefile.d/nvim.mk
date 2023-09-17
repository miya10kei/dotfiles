MASON_PKG := \
			angular-language-server \
			bash-language-server \
			docker-compose-language-service \
			dockerfile-language-server \
			flake8 \
			html-lsp \
			json-lsp \
			lua-language-server \
			python-lsp-server \
			terraform-ls \
			tflint \
			tfsec \
			typescript-language-server \
			yaml-language-server

#			goimports \
#			gopls \
#			haskell-language-server \

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
