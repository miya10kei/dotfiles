DOTDIR := $(HOME)/.dotfiles

.PHONY: build-dev-env
build-dev-env:
	docker build --progress tty --tag miya10kei/devenv:latest $(HOME)/.dotfiles

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	deploy-aws \
	deploy-git \
	deploy-gpg \
	deploy-navi \
	deploy-nvim \
	deploy-pass \
	deploy-rye \
	deploy-sheldon \
	deploy-sqls \
	deploy-starship \
	deploy-tmux \
	deploy-yamlfmt \
	deploy-zoxide \
	autoenv_auth \
	zshhistory_force
	#start-bg-job

.PHONY: install4d
install4d: \
	install-bins
	#install-aws

include Makefile.d/*.mk
