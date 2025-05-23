# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-aws
deploy-aws: \
	$(HOME)/.aws

$(HOME)/.aws:
	ln -fs $(DOTDIR)/data-volume/aws-cli $(HOME)/.aws


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-git
deploy-git: \
	gitconfig

.PHONY: gitconfig
gitconfig: $(HOME)/.gitconfig
$(HOME)/.gitconfig:
	ln -fs $(DOTDIR)/.gitconfig $(HOME)/.gitconfig

.PHONY: gitattributes
gitconfig: $(HOME)/.gitattributes
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
	gpgdir

.PHONY: gpgdir
gpgdir: $(HOME)/.gnupg
$(HOME)/.gnupg:
	ln -fs $(DOTDIR)/data-volume/gpg $(HOME)/.gnupg


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
.PHONY: deploy-mcphub
deploy-mcphub: \
  mcphubdir \
	serversjson

.PHONY: mcphubdir
mcphubdir: $(HOME)/.config/mcphub
$(HOME)/.config/mcphub:
	mkdir -p $(HOME)/.config/mcphub

.PHONY: serversjson
serversjson: $(HOME)/.config/mcphub/servers.json
$(HOME)/.config/mcphub/servers.json:
	ln -fs $(DOTDIR)/mcphub/servers.json $(HOME)/.config/mcphub/servers.json


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-navi
deploy-navi: \
	addmycheat

.PHONY: addmycheat
navidir: $(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets
$(HOME)/.local/share/navi/cheats/miya10kei__navi-cheets:
	navi repo add https://github.com/miya10kei/navi-cheets


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
.PHONY: deploy-obsidian
deploy-obsidian: \
	obsidianvimrc

obsidianvimrc: $(HOME)/.obsidian.vimrc
$(HOME)/.obsidian.vimrc:
	ln -fs $(DOTDIR)/.obsidian.vimrc $(HOME)/.obsidian.vimrc


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: deploy-sheldon
deploy-sheldon: \
	sheldondir \
	pluginstoml \
	pluginslock

.PHONY: sheldondir
sheldondir: $(HOME)/.config/sheldon
$(HOME)/.config/sheldon:
	mkdir -p $(HOME)/.config/sheldon

.PHONY: pluginstoml
pluginstoml: $(HOME)/.config/sheldon/plugins.toml
$(HOME)/.config/sheldon/plugins.toml:
	ln -fs $(DOTDIR)/plugins.toml $(HOME)/.config/sheldon/plugins.toml

.PHONY: pluginslock
pluginslock: $(HOME)/.local/share/plugins.lock
$(HOME)/.local/share/plugins.lock:
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
.PHONY: deploy-sqls
deploy-sqls: \
	sqlsdir \
	configyaml

.PHONY: sqlsdir
sqlsdir: $(HOME)/.config/sqls
$(HOME)/.config/sqls:
	mkdir -p $(HOME)/.config/sqls

.PHONY: configyaml
configyaml: $(HOME)/.config/sqls/config.yaml
$(HOME)/.config/sqls/config.yaml:
	ln -s $(DOTDIR)/.config/sqls/config.yaml $(HOME)/.config/sqls/config.yaml


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
.PHONY: deploy-yamlfmt
deploy-yamlfmt: \
	yamlfmtdir \
	yamlfmt

.PHONY: yamlfmtdir
yamlfmtdir: $(HOME)/.config/yamlfmt
$(HOME)/.config/yamlfmt:
	mkdir -p $(HOME)/.config/yamlfmt

.PHONY: yamlfmt
yamlfmt: $(HOME)/.config/yamlfmt/.yamlfmt
$(HOME)/.config/yamlfmt/.yamlfmt:
	ln -fs $(DOTDIR)/.yamlfmt $(HOME)/.config/yamlfmt/


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
