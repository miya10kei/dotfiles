BIN_DIR := $(HOME)/.local/bin
COMPLETION_DIR := $(HOME)/.local/share/zsh-completion/completions
GO_BIN_DIR := $(HOME)/go/bin
PYENV_SHIMS_DIR := $(HOME)/.pyenv/shims

AWS_VALUT := 7.2.0
BAT_VERSION := 0.24.0
BUN_VERSION := 1.0.33
DELTA_VERSION := 0.16.5
DIVE_VERSION := 0.17.0
EXA_VERSION := 0.10.1
FD_VERSION := 9.0.0
FZF_VERSION := 0.48.1
GHQ_VERSION := 1.5.0
GITHUB_CLI_VERSION := 2.46.0
JQ_VERSION := 1.7.1
NAVI_VERSION := 2.23.0
POETRY_VERSION := 1.8.2
PROCS_VERSION := 0.14.5
RIPGREP_VERSION := 13.0.0-10
SHELDON_VERSION := 0.7.4
STARSHIP_VERSION := 1.17.1
YQ_VERSION := 4.42.1
ZOXIDE_VERSION := 0.9.4

.PHONY: install-bins
install-bins: \
	$(BIN_DIR) \
	$(COMPLETION_DIR) \
	$(BIN_DIR)/aws-cli \
	aws-session-manager \
	$(BIN_DIR)/aws-vault \
	$(BIN_DIR)/bat \
	$(BIN_DIR)/bun\
	$(BIN_DIR)/delta \
	$(BIN_DIR)/dive \
	$(BIN_DIR)/exa \
	$(BIN_DIR)/fd \
	$(BIN_DIR)/fzf \
	$(BIN_DIR)/gh \
	$(BIN_DIR)/ghq \
	$(BIN_DIR)/jq \
	$(BIN_DIR)/navi \
	$(BIN_DIR)/procs \
	$(BIN_DIR)/rg \
	$(BIN_DIR)/sheldon \
	$(BIN_DIR)/starship \
	$(BIN_DIR)/tfenv \
	$(BIN_DIR)/yq \
	$(BIN_DIR)/zoxide \
	$(GO_BIN_DIR)/sqls \
	$(PYENV_SHIMS_DIR)/pgcli \
	$(PYENV_SHIMS_DIR)/poetry \
	$(PYENV_SHIMS_DIR)/sam


$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(COMPLETION_DIR):
	mkdir -p $(COMPLETION_DIR)

$(BIN_DIR)/aws-cli:
	mkdir -p /tmp/aws
	curl -fsLS -o /tmp/aws/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip
	unzip /tmp/aws/awscliv2.zip -d /tmp/aws
	/tmp/aws/aws/install --bin-dir $(BIN_DIR) --install-dir $(HOME)/.local/src
	rm -rf /tmp/aws

.PHONY: aws-session-manager
aws-session-manager: /usr/local/sessionmanagerplugin
/usr/local/sessionmanagerplugin:
	mkdir -p /tmp/sessionmanagerplugin
	curl -fsLS -o /tmp/sessionmanagerplugin/session-manager-plugin.deb https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb
	dpkg --install /tmp/sessionmanagerplugin/session-manager-plugin.deb
	rm -rf /tmp/sessionmanagerplugin

$(BIN_DIR)/aws-vault:
	curl -fsLS -o $(BIN_DIR)/aws-vault https://github.com/99designs/aws-vault/releases/download/v7.2.0/aws-vault-linux-arm64
	chmod +x $(BIN_DIR)/aws-vault

$(BIN_DIR)/bat:
	mkdir -p /tmp/bat
	curl -fsLS -o /tmp/bat/bat.tar.gz https://github.com/sharkdp/bat/releases/download/v$(BAT_VERSION)/bat-v$(BAT_VERSION)-aarch64-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/bat/bat.tar.gz -C /tmp/bat
	mv /tmp/bat/bat-v$(BAT_VERSION)-aarch64-unknown-linux-gnu/bat $(BIN_DIR)/bat
	mv /tmp/bat/bat-v$(BAT_VERSION)-aarch64-unknown-linux-gnu/autocomplete/bat.zsh $(COMPLETION_DIR)/bat.zsh
	chown `whoami`:`groups` $(BIN_DIR)/bat
	chown `whoami`:`groups` $(COMPLETION_DIR)/bat.zsh
	rm -rf /tmp/bat

$(BIN_DIR)/bun:
	curl -fsSL https://bun.sh/install | bash -s "bun-v$(BUN_VERSION)"

$(BIN_DIR)/delta:
	mkdir -p /tmp/delta
	curl -fsLS -o /tmp/delta/delta.tar.gz https://github.com/dandavison/delta/releases/download/$(DELTA_VERSION)/delta-$(DELTA_VERSION)-aarch64-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/delta/delta.tar.gz -C /tmp/delta
	mv /tmp/delta/delta-$(DELTA_VERSION)-aarch64-unknown-linux-gnu/delta $(BIN_DIR)/delta
	chown `whoami`:`groups` $(BIN_DIR)/delta
	rm -rf /tmp/delta

$(BIN_DIR)/dive:
	mkdir -p /tmp/dive
	curl -fsLS -o /tmp/dive/dive.tar.gz https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz
	tar -zxf /tmp/dive/dive.tar.gz -C /tmp/dive
	mv /tmp/dive/dive $(BIN_DIR)/dive
	chown `whoami`:`groups` $(BIN_DIR)/dive
	rm -rf /tmp/dive

$(BIN_DIR)/exa:
	mkdir -p /tmp/exa
	curl -fsLS -o /tmp/exa/exa.zip https://github.com/ogham/exa/releases/download/v$(EXA_VERSION)/exa-linux-x86_64-musl-v$(EXA_VERSION).zip
	unzip /tmp/exa/exa.zip -d /tmp/exa
	mv /tmp/exa/bin/exa $(BIN_DIR)/exa
	mv /tmp/exa/completions/exa.zsh $(COMPLETION_DIR)/exa.zsh
	rm -rf /tmp/exa

$(BIN_DIR)/fd:
	mkdir -p /tmp/fd
	curl -fsLS -o /tmp/fd/fd.tar.gz https://github.com/sharkdp/fd/releases/download/v$(FD_VERSION)/fd-v$(FD_VERSION)-aarch64-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/fd/fd.tar.gz -C /tmp/fd
	mv /tmp/fd/fd-v$(FD_VERSION)-aarch64-unknown-linux-gnu/fd $(BIN_DIR)/fd
	chown `whoami`:`groups` $(BIN_DIR)/fd
	rm -rf /tmp/fd

$(BIN_DIR)/fzf:
	mkdir -p /tmp/fzf
	curl -fsLS -o /tmp/fzf/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz
	tar -zxf /tmp/fzf/fzf.tar.gz -C /tmp/fzf
	mv /tmp/fzf/fzf $(BIN_DIR)/fzf
	chown `whoami`:`groups` $(BIN_DIR)/fzf
	rm -rf /tmp/fzf
	curl -fsLS -o $(BIN_DIR)/fzf-tmux https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux
	chmod +x $(BIN_DIR)/fzf-tmux
	curl -fsLS -o $(BIN_DIR)/fzf-key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/key-bindings.zsh
	chmod +x $(BIN_DIR)/fzf-key-bindings.zsh
	curl -fsLS -o $(COMPLETION_DIR)/fzf.zsh https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/completion.zsh

$(BIN_DIR)/gh:
	mkdir -p /tmp/gh
	curl -fsLS -o /tmp/gh/gh.tar.gz https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_arm64.tar.gz
	tar -zxf /tmp/gh/gh.tar.gz -C /tmp/gh
	mv /tmp/gh/gh_${GITHUB_CLI_VERSION}_linux_arm64/bin/gh $(BIN_DIR)/gh
	chown `whoami`:`groups` $(BIN_DIR)/gh
	rm -rf /tmp/gh

$(BIN_DIR)/ghq:
	mkdir -p /tmp/ghq
	curl -fsLS -o /tmp/ghq/ghq.zip https://github.com/x-motemen/ghq/releases/download/v$(GHQ_VERSION)/ghq_linux_arm64.zip
	unzip /tmp/ghq/ghq.zip -d /tmp/ghq
	mv /tmp/ghq/ghq_linux_arm64/ghq $(BIN_DIR)/ghq
	rm -rf /tmp/ghq

$(COMPLETION_DIR)/git-completion.zsh:
	curl -fsLS -o $(COMPLETION_DIR)/git-completion.zsh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh

$(BIN_DIR)/jq:
	curl -fsLS -o $(BIN_DIR)/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	chmod +x $(BIN_DIR)/jq

$(BIN_DIR)/navi:
	mkdir -p /tmp/navi
	curl -fsLS -o /tmp/navi/navi.tar.gz https://github.com/denisidoro/navi/releases/download/v$(NAVI_VERSION)/navi-v$(NAVI_VERSION)-aarch64-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/navi/navi.tar.gz -C /tmp/navi
	mv /tmp/navi/navi $(BIN_DIR)/navi
	chown `whoami`:`groups` $(BIN_DIR)/navi
	rm -rf /tmp/navi

$(BIN_DIR)/rg:
	mkdir -p /tmp/rg
	curl -fsLS -o /tmp/rg/rg.tar.gz https://github.com/microsoft/ripgrep-prebuilt/releases/download/v${RIPGREP_VERSION}/ripgrep-v${RIPGREP_VERSION}-aarch64-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/rg/rg.tar.gz -C /tmp/rg
	mv /tmp/rg/rg $(BIN_DIR)/rg
	chown `whoami`:`groups` $(BIN_DIR)/rg
	rm -rf /tmp/rg

$(BIN_DIR)/procs:
	mkdir -p /tmp/procs
	curl -fsLS -o /tmp/procs/procs.zip https://github.com/dalance/procs/releases/download/v0.14.0/procs-v0.14.0-x86_64-linux.zip
	unzip /tmp/procs/procs.zip -d /tmp/procs
	mv /tmp/procs/procs $(BIN_DIR)/procs
	rm -rf /tmp/procs

$(BIN_DIR)/sheldon:
	mkdir -p /tmp/sheldon
	curl -fsLS -o /tmp/sheldon/sheldon.tar.gz https://github.com/rossmacarthur/sheldon/releases/download/$(SHELDON_VERSION)/sheldon-$(SHELDON_VERSION)-aarch64-unknown-linux-musl.tar.gz
	tar -zxf /tmp/sheldon/sheldon.tar.gz -C /tmp/sheldon
	mv /tmp/sheldon/sheldon $(BIN_DIR)/sheldon
	chown `whoami`:`groups` $(BIN_DIR)/sheldon
	mv /tmp/sheldon/completions/sheldon.zsh $(COMPLETION_DIR)/sheldon.zsh
	chown `whoami`:`groups` $(COMPLETION_DIR)/sheldon.zsh

$(BIN_DIR)/starship:
	mkdir -p /tmp/starship
	curl -fsLS -o /tmp/starship/starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-aarch64-unknown-linux-musl.tar.gz
	tar -zxf /tmp/starship/starship.tar.gz -C /tmp/starship
	mv /tmp/starship/starship $(BIN_DIR)/starship
	chown `whoami`:`groups` $(BIN_DIR)/starship
	rm -rf /tmp/starship

$(BIN_DIR)/tfenv:
	git clone --depth=1 https://github.com/tfutils/tfenv.git $(HOME)/.tfenv

$(BIN_DIR)/yq:
	curl -fsLS -o $(BIN_DIR)/yq https://github.com/mikefarah/yq/releases/download/v4.32.2/yq_linux_amd64
	chmod +x $(BIN_DIR)/yq

$(BIN_DIR)/zoxide:
	mkdir -p /tmp/zoxide
	curl -fsLS -o /tmp/zoxide/zoxide.tar.gz https://github.com/ajeetdsouza/zoxide/releases/download/v$(ZOXIDE_VERSION)/zoxide-$(ZOXIDE_VERSION)-aarch64-unknown-linux-musl.tar.gz
	tar -zxf /tmp/zoxide/zoxide.tar.gz -C /tmp/zoxide
	mv /tmp/zoxide/zoxide $(BIN_DIR)/zoxide
	chown `whoami`:`groups` $(BIN_DIR)/zoxide
	rm -rf /tmp/zoxide

$(GO_BIN_DIR)/sqls:
	go install github.com/sqls-server/sqls@latest

$(PYENV_SHIMS_DIR)/poetry:
	pip install poetry

$(PYENV_SHIMS_DIR)/sam:
	pip install aws-sam-cli

$(PYENV_SHIMS_DIR)/pgcli:
	pip install pgcli
