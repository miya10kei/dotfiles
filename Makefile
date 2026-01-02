OS              := $(shell uname -s)
ARCH            := $(shell uname -m)
DOTDIR          := $(HOME)/.dotfiles
UID             := $(shell id -u)
UNAME           := $(shell id -un)
DOCKER_PROGRESS ?= tty

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
	@echo "GITHUB_TOKEN length in make: $${#GITHUB_TOKEN}"; \
	if [ -z "$$GITHUB_TOKEN" ]; then echo "ERROR: GITHUB_TOKEN is not set. Run: export GITHUB_TOKEN"; exit 1; fi
	echo "DKID=$(DKID) GID=$(GID)"; \
	if [ "$(ARCH)" = "x86_64" ]; then \
		docker build \
			--build-arg ARCH1=x86_64 \
			--build-arg ARCH2=amd64 \
			--build-arg ARCH3=x64 \
			--build-arg ARCH4=x86_64 \
			--build-arg DKID=$(DKID) \
			--build-arg GID=$(GID) \
			--build-arg GNAME=$(GNAME) \
			--build-arg UID=$(UID) \
			--build-arg UNAME=$(UNAME) \
			--secret id=GITHUB_TOKEN,env=GITHUB_TOKEN \
			--progress $(DOCKER_PROGRESS) \
			--tag miya10kei/devenv:latest \
			$(HOME)/.dotfiles; \
	else \
		docker build \
			--build-arg ARCH1=aarch64 \
			--build-arg ARCH2=arm64 \
			--build-arg ARCH3=arm64 \
			--build-arg ARCH4=arm64 \
			--build-arg DKID=$(DKID) \
			--build-arg GID=$(GID) \
			--build-arg GNAME=$(GNAME) \
			--build-arg UID=$(UID) \
			--build-arg UNAME=$(UNAME) \
			--secret id=GITHUB_TOKEN,env=GITHUB_TOKEN \
			--progress $(DOCKER_PROGRESS) \
			--tag miya10kei/devenv:latest \
			$(HOME)/.dotfiles; \
	fi
	docker system prune --force

.PHONY: setup4d
setup4d: \
	delete-nvimrc \
	deploy-aws \
	deploy-coderabbit \
	deploy-editorconfig \
	deploy-gemini \
	deploy-gh \
	deploy-git \
	deploy-github-copilot \
	deploy-gpg \
	deploy-markdownlint \
	deploy-mcpauth \
	deploy-mcphub \
	deploy-memolist \
	deploy-mise \
	deploy-nvim \
	deploy-pass \
	deploy-sheldon \
	deploy-starship \
	deploy-tmux \
	deploy-yamlfmt \
	deploy-zoxide \
	deploy-claude \
	autoenv_auth \
	zshhistory_force

.PHONY: install4d
install4d: \
	install-bins

include Makefile.d/*.mk
