ARCH   := $(shell uname -m)
DOTDIR := $(HOME)/.dotfiles
GID    := $(shell id -g)
GNAME  := $(shell id -gn)
UID    := $(shell id -u)
UNAME  := $(shell id -un)
DKID   := $(shell getent group docker | cut -d: -f3)

.PHONY: build-dev-env
build-dev-env:
	if [ "$(ARCH)" = "x86_64" ]; then \
		docker build \
			--build-arg ARCH1=x86_64 \
			--build-arg ARCH2=amd64 \
			--build-arg ARCH3=x64 \
			--build-arg DKID=$(DKID) \
			--build-arg GID=$(GID) \
			--build-arg GNAME=$(GNAME) \
			--build-arg UID=$(UID) \
			--build-arg UNAME=$(UNAME) \
			--progress tty \
			--tag miya10kei/devenv:latest \
			$(HOME)/.dotfiles; \
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
