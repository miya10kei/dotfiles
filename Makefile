DOTDIR := $(HOME)/.dotfiles

.PHONY: build-dev-env
build-dev-env:
	docker build --progress=plain --tag miya10kei/devenv:latest $(HOME)/.dotfiles

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	delete-zshhistory \
	deploy-aws \
	deploy-git \
	deploy-nvim \
	deploy-starship \
	deploy-tmux \
	deploy-zoxide \
	zshhistory \
	start-bg-job

.PHONY: install4d
install4d: \
	install-bins \
	install-aws

include Makefile.d/*.mk
