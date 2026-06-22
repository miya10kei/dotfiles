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
	mkdir -p $(HOME)/.local/share/zsh-completion/completions
	mise completion zsh > $(HOME)/.local/share/zsh-completion/completions/_mise


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-aws
deploy-aws: \
	$(HOME)/.config/aws

$(HOME)/.config/aws:
	ln -fns $(DOTDIR)/config/aws $(HOME)/.config/aws


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-ccstatusline
deploy-ccstatusline: \
	$(HOME)/.config/ccstatusline

$(HOME)/.config/ccstatusline:
	ln -fns $(DOTDIR)/config/ccstatusline $(HOME)/.config/ccstatusline


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-coderabbit
deploy-coderabbit: \
	$(HOME)/.coderabbit

$(HOME)/.coderabbit:
	ln -fns $(DOTDIR)/data-volume/coderabbit $(HOME)/.coderabbit


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-claude
deploy-claude: \
	$(HOME)/.config/claude

$(HOME)/.config/claude:
	ln -fns $(DOTDIR)/config/claude $(HOME)/.config/claude


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-editorconfig
deploy-editorconfig: \
	$(HOME)/.editorconfig

$(HOME)/.editorconfig:
	ln -fns $(DOTDIR)/.editorconfig $(HOME)/.editorconfig


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
.PHONY: deploy-gws
deploy-gws: \
	$(HOME)/.config/gws

$(HOME)/.config/gws:
	ln -fns $(DOTDIR)/config/gws $(HOME)/.config/gws


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-gpg
deploy-gpg: \
	$(HOME)/.gnupg

$(HOME)/.gnupg:
	ln -fns $(DOTDIR)/data-volume/gpg $(HOME)/.gnupg


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
.PHONY: deploy-navi
deploy-navi: \
	$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets

$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets:
	navi repo add https://github.com/miya10kei/navi-cheets


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-npm
deploy-npm: \
	$(HOME)/.config/npm

$(HOME)/.config/npm:
	ln -fns $(DOTDIR)/config/npm $(HOME)/.config/npm


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
.PHONY: deploy-sheldon
deploy-sheldon: \
	$(HOME)/.config/sheldon \
	$(HOME)/.local/share/sheldon/plugins.lock

$(HOME)/.config/sheldon:
	ln -fns $(DOTDIR)/config/sheldon $(HOME)/.config/sheldon

$(HOME)/.local/share/sheldon/plugins.lock:
	sheldon lock


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-pip
deploy-pip: \
	$(HOME)/.config/pip

$(HOME)/.config/pip:
	ln -fns $(DOTDIR)/config/pip $(HOME)/.config/pip


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-pass
deploy-pass: \
	passwordstore

.PHONY: passwordstore
passwordstore: $(HOME)/.password-store
$(HOME)/.password-store:
	ln -s $(DOTDIR)/data-volume/pass $(HOME)/.password-store


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-taplo
deploy-taplo: \
	$(HOME)/.config/taplo

$(HOME)/.config/taplo:
	ln -fns $(DOTDIR)/config/taplo $(HOME)/.config/taplo


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
.PHONY: deploy-uv
deploy-uv: \
	$(HOME)/.config/uv

$(HOME)/.config/uv:
	ln -fns $(DOTDIR)/config/uv $(HOME)/.config/uv


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
	zprofile \
	zshrc


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
