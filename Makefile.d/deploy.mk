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
# symlinkの配置は mise.toml の [dotfiles] で定義する。miseはsourceが1つでも欠けると何も配置しないため、
# 永続化用のdata-volumeを先に用意する。--force は配置先の実体をデータごと消すため使わず、
# 置き換えてよい実体（イメージにCOPYされた ~/.config/nvim、zshが作った ~/.zsh_history）だけを先に消す
.PHONY: deploy-dotfiles
deploy-dotfiles:
	mkdir -p $(DOTDIR)/data-volume/pass $(DOTDIR)/data-volume/zoxide $(DOTDIR)/data-volume/zsh-history
	mkdir -p -m 700 $(DOTDIR)/data-volume/gpg
	touch $(DOTDIR)/data-volume/zsh-history/.zsh_history
	if [ -e $(HOME)/.config/nvim ] && [ ! -L $(HOME)/.config/nvim ]; then rm -rf $(HOME)/.config/nvim; fi
	if [ -f $(HOME)/.zsh_history ] && [ ! -L $(HOME)/.zsh_history ]; then rm -f $(HOME)/.zsh_history; fi
	mise trust --quiet $(DOTDIR)/mise.toml
	mise --cd $(DOTDIR) dotfiles apply --yes


# ----------------------------------------------------------------------------------------------------------------------
# CodeRabbit CLI はログディレクトリまでのパスに symlink があると起動しないため、ディレクトリは実体にし、
# 永続化するファイルだけを data-volume へリンクする
CODERABBIT_PERSISTENT_FILES := auth.json doctor.json rate-limit-cooldown.json stats.json reviews

.PHONY: deploy-coderabbit
deploy-coderabbit:
	if [ -L $(HOME)/.coderabbit ]; then rm $(HOME)/.coderabbit; fi
	mkdir -p $(HOME)/.coderabbit/logs $(DOTDIR)/data-volume/coderabbit/reviews
	chmod 700 $(HOME)/.coderabbit $(HOME)/.coderabbit/logs
	for f in $(CODERABBIT_PERSISTENT_FILES); do \
		ln -fns $(DOTDIR)/data-volume/coderabbit/$$f $(HOME)/.coderabbit/$$f; \
	done


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
.PHONY: deploy-karabiner
deploy-karabiner: \
	$(HOME)/.config/karabiner/karabiner.json

$(HOME)/.config/karabiner/karabiner.json:
	ln -fns $(DOTDIR)/karabiner.json $(HOME)/.config/karabiner/karabiner.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-navi
deploy-navi: \
	$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets

$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets:
	navi repo add https://github.com/miya10kei/navi-cheets


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-sheldon
deploy-sheldon: \
	$(HOME)/.local/share/sheldon/plugins.lock

$(HOME)/.local/share/sheldon/plugins.lock:
	sheldon lock


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

.PHONY: delete-zshhistory
delete-zshhistory:
	rm -rf $(HOME)/.zsh_history
