DOTDIR := ~/.dotfiles

.PHONY: deploy
deploy: \
	fish-deploy \
	tmux-deploy \
	git-deploy


.PHONY: fish-deploy
fish-deploy: \
	config.fish \
	fishfile

.PHONY: config.fish
config.fish: $(HOME)/.config/fish/config.fish
$(HOME)/.config/fish/config.fish:
	mkdir -p $(HOME)/.config/fish
	ln -s $(DOTDIR)/config.fish  $(HOME)/.config/fish/config.fish

.PHONY: fishfile
fishfile: $(HOME)/.config/fish/fishfile
$(HOME)/.config/fish/fishfile:
	mkdir -p $(HOME)/.config/fish
	ln -s $(DOTDIR)/fishfile $(HOME)/.config/fish/fishfile


.PHONY: tmux-deploy
tmux-deploy: \
	tmux.conf

.PHONY: tmux.conf
tmux.conf: $(HOME)/.tmux.conf
$(HOME)/.tmux.conf:
	ln -s $(DOTDIR)/.tmux.conf $(HOME)/.tmux.conf


.PHONY: git-deploy
git-deploy: \
	gitconfig \
	gitconfig_private

.PHONY: gitconfig
gitconfig: $(HOME)/.gitconfig
$(HOME)/.gitconfig:
	ln -s $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

.PHONY: gitconfig_private
gitconfig: $(HOME)/.gitconfig_private
$(HOME)/.gitconfig_private:
	ln -s $(DOTDIR)/.gitconfig_private $(HOME)/.gitconfig_private
