OS     := $(shell uname -s)
ARCH   := $(shell uname -m)
DOTDIR := $(HOME)/.dotfiles
UID    := $(shell id -u)
UNAME  := $(shell id -un)

ifeq ($(OS), Darwin)
	GNAME := $(UNAME)
	GID   := 1001
	DKID  := 1002
else
	GNAME  := $(shell id -gn)
	GID  := $(shell id -g)
	DKID := $(shell getent group docker | cut -d: -f3)
endif

.PHONY: build-dev-env
build-dev-env:
	echo "DKID=$(DKID) GID=$(GID)"; \
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
		docker build \
			--build-arg ARCH1=aarch64 \
			--build-arg ARCH2=arm64 \
			--build-arg ARCH3=arm64 \
			--build-arg DKID=$(DKID) \
			--build-arg GID=$(GID) \
			--build-arg GNAME=$(GNAME) \
			--build-arg UID=$(UID) \
			--build-arg UNAME=$(UNAME) \
			--progress tty \
			--tag miya10kei/devenv:latest \
			$(HOME)/.dotfiles; \
	fi
	docker system prune --force

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	deploy-aws \
	deploy-claude \
	deploy-git \
	deploy-github-copilot \
	deploy-gpg \
	deploy-mcphub \
	deploy-memolist \
	deploy-nvim \
	deploy-pass \
	deploy-sheldon \
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
