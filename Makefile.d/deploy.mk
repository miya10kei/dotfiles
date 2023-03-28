# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-aws
deploy-aws: \
	$(HOME)/.aws

$(HOME)/.aws: 
	ln -fs $(DOTDIR)/.aws $(HOME)/.aws
# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-git
deploy-git: \
	gitconfig \

.PHONY: gitconfig
gitconfig: $(HOME)/.gitconfig
$(HOME)/.gitconfig:
	ln -fs $(DOTDIR)/.gitconfig $(HOME)/.gitconfig


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-hyper
deploy-hyper: \
	hyperjs

.PHONY: hyperjs
hyperjs: $(HOME).hyper.js
$(HOME).hyper.js:
	ln -fs $(DOTDIR)/.hyper.js $(HOME)/.hyper.js


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-karabiner
deploy-karabiner: \
	karabinerjson

.PHONY: karabinerjson
karabinerjson: $(HOME)/.config/karabiner/karabiner.json
$(HOME)/.config/karabiner/karabiner.json: 
	ln -fs $(DOTDIR)/karabiner.json $(HOME)/.config/karabiner/karabiner.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-nvim
deploy-nvim: \
	nvimrc

.PHONY: nvimrc
nvimrc: $(HOME)/.config/nvim
$(HOME)/.config/nvim:
	ln -fs $(DOTDIR)/nvim/ $(HOME)/.config/

.PHONY: delete-nvimrc
delete-nvimrc:
	rm -rf $(HOME)/.config/nvim


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-starship
deploy-starship: \
	starshiptoml

.PHONY: startshiptoml
starshiptoml: $(HOME)/.config/starship.toml
$(HOME)/.config/starship.toml:
	ln -fs $(DOTDIR)/starship.toml $(HOME)/.config/starship.toml


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-tmux
deploy-tmux: \
	tmuxconf

.PHONY: tmuxconf
tmuxconf: $(HOME)/.tmux.conf
$(HOME)/.tmux.conf:
	ln -fs $(DOTDIR)/.tmux.conf $(HOME)/.tmux.conf


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-zsh
deploy-zsh: \
	zprofile \
	zshrc

.PHONY: zprofile
zprofile: $(HOME)/.zprofile
$(HOME)/.zprofile:
	ln -fs $(DOTDIR)/.zprofile $(HOME)/.zprofile

.PHONY: zshrc
zshrc: $(HOME)/.zshrc
$(HOME)/.zshrc:
	ln -fs $(DOTDIR)/.zshrc $(HOME)/.zshrc

.PHONY: zshhistory
zshhistory: $(HOME)/.zsh_history
$(HOME)/.zsh_history:
	ln -fs $(DOTDIR)/.zsh_history $(HOME)/.zsh_history
