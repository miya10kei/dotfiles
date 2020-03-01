DOTDIR := ~/.dotfiles

.PHONY: deploy
deploy: \
	fish-deploy \
	git-deploy \
	tmux-deploy \
	vim-deploy


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
	gitconfig_private \
	gitconfig_work \
	gitmessage

.PHONY: gitconfig
gitconfig: $(HOME)/.gitconfig
$(HOME)/.gitconfig:
	ln -s $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

.PHONY: gitconfig_private
gitconfig_private: $(HOME)/.gitconfig_private
$(HOME)/.gitconfig_private:
	ln -s $(DOTDIR)/.gitconfig_private $(HOME)/.gitconfig_private

.PHONY: gitconfig_work
gitconfig_work: $(HOME)/.gitconfig_work
$(HOME)/.gitconfig_work:
	ln -s $(DOTDIR)/.gitconfig_work $(HOME)/.gitconfig_work

.PHONY: gitmessage
gitmessage: $(HOME)/.gitmessage
$(HOME)/.gitmessage:
	ln -s $(DOTDIR)/.gitmessage $(HOME)/.gitmessage


.PHONY: vim-deploy
vim-deploy: \
	init.vim \
	coc-settings.json \
	install-plugin

.PHONY: init.vim
init.vim: $(HOME)/.config/nvim/init.vim
$(HOME)/.config/nvim/init.vim:
	mkdir -p $(HOME)/.config/nvim
	ln -s $(DOTDIR)/init.vim $(HOME)/.config/nvim/init.vim

.PHONY: coc-settings.json
coc-settings.json: $(HOME)/.config/nvim/coc-settings.json
$(HOME)/.config/nvim/coc-settings.json:
	mkdir -p $(HOME)/.config/nvim
	ln -s $(DOTDIR)/coc-settings.json $(HOME)/.config/nvim/coc-settings.json

.PHONY: install-plugin
install-plugin:
	nvim --headless +PlugInstall +qall

.PHONY: build-devenv
build-devenv:
	docker build . -t devenv

C := miya10kei@gmail.com
.PHONY: create-sshkey
create-sshkey:
	ssh-keygen -t rsa -b 4096 -C ${C}
