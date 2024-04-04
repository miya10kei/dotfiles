ARCH := $(shell uname -m)
DOTDIR := $(HOME)/.dotfiles

.PHONY: build-dev-env
build-dev-env:
	if [ "$(ARCH)" = "x86_64" ]; then \
		docker build --progress tty --tag miya10kei/devenv:latest --build-arg ARCH1=x86_64 --build-arg ARCH2=amd64 --build-arg ARCH3=x64 $(HOME)/.dotfiles; \
	else \
		docker build --progress tty --tag miya10kei/devenv:latest $(HOME)/.dotfiles; \
	fi

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	deploy-aws \
	deploy-git \
	deploy-gpg \
	deploy-navi \
	deploy-nvim \
	deploy-pass \
	deploy-sheldon \
	deploy-sqls \
	deploy-starship \
	deploy-tmux \
	deploy-yamlfmt \
	deploy-zoxide \
	autoenv_auth \
	zshhistory_force

.PHONY: install4d
install4d: \
	install-bins

include Makefile.d/*.mk
