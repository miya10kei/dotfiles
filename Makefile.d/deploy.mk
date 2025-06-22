# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-aws
deploy-aws: \
	$(HOME)/.aws

$(HOME)/.aws:
	ln -fs $(DOTDIR)/data-volume/aws-cli $(HOME)/.aws


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-claude
deploy-claude: \
	$(HOME)/.claude

$(HOME)/.claude:
	ln -fs $(DOTDIR)/data-volume/claude $(HOME)/.claude


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-editorconfig
deploy-editorconfig: \
	$(HOME)/.editorconfig

$(HOME)/.editorconfig:
	ln -fs $(DOTDIR)/.editorconfig $(HOME)/.editorconfig


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-git
deploy-git: \
	$(HOME)/.gitconfig \
	$(HOME)/.gitattributes

$(HOME)/.gitconfig:
	ln -fs $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

$(HOME)/.gitattributes:
	ln -fs $(DOTDIR)/.gitattributes $(HOME)/.gitattributes


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-github-copilot
deploy-github-copilot: \
	$(HOME)/.config/github-copilot

$(HOME)/.config/github-copilot:
	ln -fs $(DOTDIR)/data-volume/github-copilot $(HOME)/.config/github-copilot


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-gpg
deploy-gpg: \
	$(HOME)/.gnupg

$(HOME)/.gnupg:
	ln -fs $(DOTDIR)/data-volume/gpg $(HOME)/.gnupg


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-hyper
deploy-hyper: \
	$(HOME).hyper.js

$(HOME).hyper.js:
	ln -fs $(DOTDIR)/.hyper.js $(HOME)/.hyper.js


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-karabiner
deploy-karabiner: \
	$(HOME)/.config/karabiner/karabiner.json

$(HOME)/.config/karabiner/karabiner.json:
	ln -fs $(DOTDIR)/karabiner.json $(HOME)/.config/karabiner/karabiner.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-mcphub
deploy-mcphub: \
  $(HOME)/.config/mcphub

$(HOME)/.config/mcphub:
	ln -fs $(DOTDIR)/config/mcphub $(HOME)/.config/mcphub


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
	ln -fs $(DOTDIR)/config/memo $(HOME)/.config/memo


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-nvim
deploy-nvim: \
	$(HOME)/.config/nvim

$(HOME)/.config/nvim:
	ln -fs $(DOTDIR)/config/nvim/ $(HOME)/.config/nvim

.PHONY: delete-nvimrc
delete-nvimrc:
	rm -rf $(HOME)/.config/nvim


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-obsidian
deploy-obsidian: \
	obsidianvimrc

obsidianvimrc: $(HOME)/.obsidian.vimrc
$(HOME)/.obsidian.vimrc:
	ln -fs $(DOTDIR)/.obsidian.vimrc $(HOME)/.obsidian.vimrc


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-sheldon
deploy-sheldon: \
	$(HOME)/.config/sheldon \
	sheldonlock

$(HOME)/.config/sheldon:
	ln -fs $(DOTDIR)/config/sheldon $(HOME)/.config/sheldon

sheldonlock:
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
	ln -fs $(DOTDIR)/config/starship.toml $(HOME)/.config/starship.toml


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-tmux
deploy-tmux: \
	tmuxconf

.PHONY: tmuxconf
tmuxconf: $(HOME)/.tmux.conf
$(HOME)/.tmux.conf:
	ln -fs $(DOTDIR)/.tmux.conf $(HOME)/.tmux.conf


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-yamlfmt
deploy-yamlfmt: \
	$(HOME)/.config/yamlfmt


$(HOME)/.config/yamlfmt:
	ln -fs $(DOTDIR)/config/yamlfmt $(HOME)/.config/yamlfmt


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-zoxide
deploy-zoxide: \
	zoxide

.PHONY: zoxide
zoxide: $(HOME)/.local/share/zoxide
$(HOME)/.local/share/zoxide:
	ln -fs $(DOTDIR)/data-volume/zoxide/ $(HOME)/.local/share/


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
	ln -fs $(DOTDIR)/data-volume/zsh-autoenv/autoenv_auth $(HOME)/.local/share/autoenv_auth


# ----------------------------------------------------------------------------------------------------------------------
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
	ln -fs $(DOTDIR)/data-volume/zsh-history/.zsh_history $(HOME)/.zsh_history

.PHONY: zshhistory_force
zshhistory_force:
	ln -fs $(DOTDIR)/data-volume/zsh-history/.zsh_history $(HOME)/.zsh_history

.PHONY: delete-zshhistory
delete-zshhistory:
	rm -rf $(HOME)/.zsh_history
