# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-docker
deploy-docker: \
	$(HOME)/.config/docker/cli-plugins/docker-buildx \
	$(HOME)/.config/docker/cli-plugins/docker-compose

$(HOME)/.config/docker/cli-plugins/docker-buildx:
	mkdir -p $(HOME)/.config/docker/cli-plugins
	ln -sf $$(mise where aqua:docker/buildx)/docker-cli-plugin-docker-buildx $(HOME)/.config/docker/cli-plugins/docker-buildx

$(HOME)/.config/docker/cli-plugins/docker-compose:
	mkdir -p $(HOME)/.config/docker/cli-plugins
	ln -sf $$(mise where aqua:docker/compose)/docker-cli-plugin-docker-compose $(HOME)/.config/docker/cli-plugins/docker-compose


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-mise
deploy-mise:
	@if [ -d $(HOME)/.config/mise ] && [ ! -L $(HOME)/.config/mise ]; then rm -rf $(HOME)/.config/mise; fi
	ln -fns $(DOTDIR)/config/mise $(HOME)/.config/mise


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-aws
deploy-aws: \
	$(HOME)/.config/aws

$(HOME)/.config/aws:
	ln -fns $(DOTDIR)/config/aws $(HOME)/.config/aws


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-coderabbit
deploy-coderabbit: \
	$(HOME)/.coderabbit \
	$(HOME)/.coderabbit/auth.json

$(HOME)/.coderabbit:
	mkdir -p $(HOME)/.coderabbit

$(HOME)/.coderabbit/auth.json:
	ln -fns $(DOTDIR)/data-volume/coderabbit/auth.json $(HOME)/.coderabbit/auth.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-claude
deploy-claude: \
	$(HOME)/.config/claude \
	install-claude-mcp-servers

$(HOME)/.config/claude:
	ln -fns $(DOTDIR)/config/claude $(HOME)/.config/claude

install-claude-mcp-servers:
	bash $(HOME)/.config/claude/scripts/install-mcp-servers.sh
	@if [ -f $(HOME)/.config/claude/scripts/install-mcp-servers-work.sh ]; then \
		bash $(HOME)/.config/claude/scripts/install-mcp-servers-work.sh; \
	fi


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-editorconfig
deploy-editorconfig: \
	$(HOME)/.editorconfig

$(HOME)/.editorconfig:
	ln -fns $(DOTDIR)/.editorconfig $(HOME)/.editorconfig


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-gemini
deploy-gemini: \
	$(HOME)/.gemini

$(HOME)/.gemini:
	ln -fns $(DOTDIR)/data-volume/gemini $(HOME)/.gemini


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-gh
deploy-gh: \
	$(HOME)/.config/gh \
	$(HOME)/.config/gh/config.yml

$(HOME)/.config/gh:
	ln -fns $(DOTDIR)/data-volume/gh $(HOME)/.config/gh

$(HOME)/.config/gh/config.yml:
	ln -fns $(DOTDIR)/config/gh/config.yml $(HOME)/.config/gh/config.yml


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-git
deploy-git: \
	$(HOME)/.gitconfig \
	$(HOME)/.gitattributes

$(HOME)/.gitconfig:
	ln -fns $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

$(HOME)/.gitattributes:
	ln -fns $(DOTDIR)/.gitattributes $(HOME)/.gitattributes


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-github-copilot
deploy-github-copilot: \
	$(HOME)/.config/github-copilot

$(HOME)/.config/github-copilot:
	ln -fns $(DOTDIR)/data-volume/github-copilot $(HOME)/.config/github-copilot


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-gpg
deploy-gpg: \
	$(HOME)/.gnupg

$(HOME)/.gnupg:
	ln -fns $(DOTDIR)/data-volume/gpg $(HOME)/.gnupg


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-hyper
deploy-hyper: \
	$(HOME).hyper.js

$(HOME).hyper.js:
	ln -fns $(DOTDIR)/.hyper.js $(HOME)/.hyper.js


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-karabiner
deploy-karabiner: \
	$(HOME)/.config/karabiner/karabiner.json

$(HOME)/.config/karabiner/karabiner.json:
	ln -fns $(DOTDIR)/karabiner.json $(HOME)/.config/karabiner/karabiner.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-markdownlint
deploy-markdownlint: \
	$(HOME)/.markdownlintrc

$(HOME)/.markdownlintrc:
	ln -fns $(DOTDIR)/.markdownlintrc $(HOME)/.markdownlintrc


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-mcpauth
deploy-mcpauth: \
  $(HOME)/.mcp-auth

$(HOME)/.mcp-auth:
	ln -fns $(DOTDIR)/data-volume/mcp-auth $(HOME)/.mcp-auth


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-mcphub
deploy-mcphub: \
  $(HOME)/.config/mcphub

$(HOME)/.config/mcphub:
	ln -fns $(DOTDIR)/config/mcphub $(HOME)/.config/mcphub


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-navi
deploy-navi: \
	$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets

$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets:
	navi repo add https://github.com/miya10kei/navi-cheets


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-memolist
deploy-memolist: \
	$(HOME)/.config/memo

$(HOME)/.config/memo:
	ln -fns $(DOTDIR)/config/memo $(HOME)/.config/memo


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-nvim
deploy-nvim: \
	$(HOME)/.config/nvim

$(HOME)/.config/nvim:
	ln -fns $(DOTDIR)/config/nvim $(HOME)/.config/nvim

.PHONY: delete-nvimrc
delete-nvimrc:
	rm -rf $(HOME)/.config/nvim


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-obsidian
deploy-obsidian: \
	obsidianvimrc

obsidianvimrc: $(HOME)/.obsidian.vimrc
$(HOME)/.obsidian.vimrc:
	ln -fns $(DOTDIR)/.obsidian.vimrc $(HOME)/.obsidian.vimrc


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-sheldon
deploy-sheldon: \
	$(HOME)/.config/sheldon \
	$(HOME)/.local/share/sheldon/plugins.lock

$(HOME)/.config/sheldon:
	ln -fns $(DOTDIR)/config/sheldon $(HOME)/.config/sheldon

$(HOME)/.local/share/sheldon/plugins.lock:
	sheldon lock


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-pass
deploy-pass: \
	passwordstore

.PHONY: passwordstore
passwordstore: $(HOME)/.password-store
$(HOME)/.password-store:
	ln -s $(DOTDIR)/data-volume/pass $(HOME)/.password-store


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-starship
deploy-starship: \
	$(HOME)/.config/starship.toml

$(HOME)/.config/starship.toml:
	ln -fns $(DOTDIR)/config/starship.toml $(HOME)/.config/starship.toml


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-tmux
deploy-tmux: \
	$(HOME)/.config/tmux

$(HOME)/.config/tmux:
	ln -fns $(DOTDIR)/config/tmux $(HOME)/.config/tmux


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-yamlfmt
deploy-yamlfmt: \
	$(HOME)/.config/yamlfmt


$(HOME)/.config/yamlfmt:
	ln -fns $(DOTDIR)/config/yamlfmt $(HOME)/.config/yamlfmt


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-zoxide
deploy-zoxide: \
	zoxide

.PHONY: zoxide
zoxide: $(HOME)/.local/share/zoxide
$(HOME)/.local/share/zoxide:
	ln -fns $(DOTDIR)/data-volume/zoxide $(HOME)/.local/share/zoxide


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-zsh
deploy-zsh: \
	autoenv_auth \
	zprofile \
	zshrc


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: autoenv_auth
autoenv_auth: $(HOME)/.local/share/autoenv_auth
$(HOME)/.local/share/autoenv_auth:
	ln -fns $(DOTDIR)/data-volume/zsh-autoenv/autoenv_auth $(HOME)/.local/share/autoenv_auth


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: zprofile
zprofile: $(HOME)/.zprofile
$(HOME)/.zprofile:
	ln -fns $(DOTDIR)/.zprofile $(HOME)/.zprofile

.PHONY: zshrc
zshrc: $(HOME)/.zshrc
$(HOME)/.zshrc:
	ln -fns $(DOTDIR)/.zshrc $(HOME)/.zshrc

.PHONY: zshhistory
zshhistory: $(HOME)/.zsh_history
$(HOME)/.zsh_history:
	ln -fns $(DOTDIR)/data-volume/zsh-history/.zsh_history $(HOME)/.zsh_history

.PHONY: zshhistory_force
zshhistory_force:
	ln -fns $(DOTDIR)/data-volume/zsh-history/.zsh_history $(HOME)/.zsh_history

.PHONY: delete-zshhistory
delete-zshhistory:
	rm -rf $(HOME)/.zsh_history
