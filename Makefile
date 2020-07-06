DOTDIR := ~/.dotfiles

.PHONY: deploy
deploy: \
	fish-deploy \
	git-deploy \
	idea-deploy \
	tmux-deploy \
	vim-deploy


# ------------
# --- fish ---
# ------------
.PHONY: fish-deploy
fish-deploy: \
	config.fish \
	fishfile \
	install-fish-plugin

.PHONY: config.fish
config.fish: $(HOME)/.config/fish/config.fish
$(HOME)/.config/fish/config.fish:
	mkdir -p $(HOME)/.config/fish
	ln -fs $(DOTDIR)/config.fish  $(HOME)/.config/fish/config.fish

.PHONY: fishfile
fishfile: $(HOME)/.config/fish/fishfile
$(HOME)/.config/fish/fishfile:
	mkdir -p $(HOME)/.config/fish
	ln -fs $(DOTDIR)/fishfile $(HOME)/.config/fish/fishfile

.PHONY: install-fish-plugin
install-fish-plugin:
	/usr/bin/fish -c fisher


# -----------
# --- git ---
# -----------
.PHONY: git-deploy
git-deploy: \
	gitconfig \
	gitconfig_private \
	gitconfig_work \
	gitmessage

.PHONY: gitconfig
gitconfig: $(HOME)/.gitconfig
$(HOME)/.gitconfig:
	ln -fs $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

.PHONY: gitconfig_private
gitconfig_private: $(HOME)/.gitconfig_private
$(HOME)/.gitconfig_private:
	ln -fs $(DOTDIR)/.gitconfig_private $(HOME)/.gitconfig_private

.PHONY: gitconfig_work
gitconfig_work: $(HOME)/.gitconfig_work
$(HOME)/.gitconfig_work:
	ln -fs $(DOTDIR)/.gitconfig_work $(HOME)/.gitconfig_work

.PHONY: gitmessage
gitmessage: $(HOME)/.gitmessage
$(HOME)/.gitmessage:
	ln -fs $(DOTDIR)/.gitmessage $(HOME)/.gitmessage


# ------------
# --- idea ---
# ------------
.PHONY: idea-deploy
idea-deploy: \
	ideavimrc

.PHONY: ideavimrc
ideavimrc: $(HOME)/.ideavimrc
$(HOME)/.ideavimrc:
	ln -fs $(DOTDIR)/.ideavimrc $(HOME)/.ideavimrc


# ------------
# --- tmux ---
# ------------
.PHONY: tmux-deploy
tmux-deploy: \
	tmux.conf

.PHONY: tmux.conf
tmux.conf: $(HOME)/.tmux.conf
$(HOME)/.tmux.conf:
	ln -fs $(DOTDIR)/.tmux.conf $(HOME)/.tmux.conf


# -----------
# --- vim ---
# -----------
.PHONY: vim-deploy
vim-deploy: \
	init.vim \
	coc-settings.json \
	install-vim-plugin

.PHONY: init.vim
init.vim: $(HOME)/.config/nvim/init.vim
$(HOME)/.config/nvim/init.vim:
	mkdir -p $(HOME)/.config/nvim
	ln -fs $(DOTDIR)/init.vim $(HOME)/.config/nvim/init.vim

.PHONY: coc-settings.json
coc-settings.json: $(HOME)/.config/nvim/coc-settings.json
$(HOME)/.config/nvim/coc-settings.json:
	mkdir -p $(HOME)/.config/nvim
	ln -fs $(DOTDIR)/coc-settings.json $(HOME)/.config/nvim/coc-settings.json

# .PHONY: package.json
# package.json: $(HOME)/.config/coc/extensions/package.json
# $(HOME)/.config/coc/extensions/package.json:
# 	mkdir -p $(HOME)/.config/coc/extensions
# 	ln -fs $(DOTDIR)/coc-package.json $(HOME)/.config/coc/extensions/package.json

.PHONY: install-vim-plugin
install-vim-plugin:
	nvim -u $(HOME)/.config/nvim/init.vim --headless +PlugInstall +qa
#	cd $(HOME)/.config/coc/extensions
#	npm install

# ------------
# --- util ---
# ------------
.PHONY: build-devenv
build-devenv:
	docker build . -t devenv

C := miya10kei@gmail.com
.PHONY: create-sshkey
create-sshkey:
	ssh-keygen -t rsa -b 4096 -C ${C}

.PHONY: create-dir
create-dir:
	mkdir -p \
		$(HOME)/.cache/JetBrains \
		$(HOME)/.cf \
		$(HOME)/.config/JetBrains \
		$(HOME)/.dotfiles \
		$(HOME)/.gradle \
		$(HOME)/.java \
		$(HOME)/.kube \
		$(HOME)/.local/share/JetBrains \
		$(HOME)/.m2 \
		$(HOME)/.sbt \
		$(HOME)/dev
