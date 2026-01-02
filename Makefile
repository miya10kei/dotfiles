OS              := $(shell uname -s)
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
	docker build \
		--build-arg DKID=$(DKID) \
		--build-arg GID=$(GID) \
		--build-arg GNAME=$(GNAME) \
		--build-arg UID=$(UID) \
		--build-arg UNAME=$(UNAME) \
		--secret id=GITHUB_TOKEN,env=GITHUB_TOKEN \
		--progress $(DOCKER_PROGRESS) \
		--tag miya10kei/devenv:latest \
		$(HOME)/.dotfiles
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

include Makefile.d/*.mk
