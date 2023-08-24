DOTDIR := $(HOME)/.dotfiles

.PHONY: build-dev-env
build-dev-env:
	docker build --tag miya10kei/devenv:latest $(HOME)/.dotfiles

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	deploy-aws \
	deploy-git \
	deploy-gpg \
	deploy-nvim \
	deploy-pass \
	deploy-rye \
	deploy-sheldon \
	deploy-starship \
	deploy-tmux \
	deploy-zoxide \
	autoenv_auth \
	zshhistory_force
	#start-bg-job

.PHONY: install4d
install4d: \
	install-bins
	#install-aws

include Makefile.d/*.mk
