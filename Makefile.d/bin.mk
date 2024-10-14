ARCH := $(shell uname -m)
BIN_DIR := $(HOME)/.local/bin
SRC_DIR := $(HOME)/.local/src
CARGO_BIN_DIR := $(CARGO_HOME)/bin
COMPLETION_DIR := $(HOME)/.local/share/zsh-completion/completions
FLUTTER_DIR := $(HOME)/.flutter
GO_BIN_DIR := $(HOME)/go/bin
PYENV_SHIMS_DIR := $(HOME)/.pyenv/shims

AWS_VALUT := 7.2.0
BAT_VERSION := 0.24.0
DELTA_VERSION := 0.18.2
DIVE_VERSION := 0.12.0
EXA_VERSION := 0.10.1
FD_VERSION := 10.2.0
FLUTTER_VERSION := 3.19.5
FZF_VERSION := 0.55.0
GCLOUD_VERSION := 477.0.0
GHQ_VERSION := 1.6.2
GITHUB_CLI_VERSION := 2.56.0
JQ_VERSION := 1.7.1
NAVI_VERSION := 2.23.0
PROCS_VERSION := 0.14.6
RIPGREP_VERSION := 14.1.0
SHELDON_VERSION := 0.8.0
STARSHIP_VERSION := 1.20.1
YQ_VERSION := 4.44.3
ZOXIDE_VERSION := 0.9.5

.PHONY: install-bins
install-bins: \
	$(BIN_DIR) \
	$(COMPLETION_DIR) \
	$(BIN_DIR)/aws-cli \
	aws-session-manager \
	$(BIN_DIR)/aws-vault \
	$(BIN_DIR)/bat \
	$(BIN_DIR)/bun \
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
	$(BIN_DIR)/uv \
	$(BIN_DIR)/yq \
	$(BIN_DIR)/zoxide \
	$(CARGO_BIN_DIR)/jnv \
	$(FLUTTER_DIR)/flutter \
	$(PYENV_SHIMS_DIR)/pgcli \
	$(PYENV_SHIMS_DIR)/poetry \
	$(PYENV_SHIMS_DIR)/sam \
	$(SRC_DIR)/google-cloud-sdk

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(COMPLETION_DIR):
	mkdir -p $(COMPLETION_DIR)

$(BIN_DIR)/aws-cli:
	mkdir -p /tmp/aws
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/aws/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-$(DL_ARCH).zip
	unzip -q /tmp/aws/awscliv2.zip -d /tmp/aws
	/tmp/aws/aws/install --bin-dir $(BIN_DIR) --install-dir $(HOME)/.local/src
	rm -rf /tmp/aws

.PHONY: aws-session-manager
aws-session-manager: /usr/local/sessionmanagerplugin
/usr/local/sessionmanagerplugin:
	mkdir -p /tmp/sessionmanagerplugin
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "64bit"; else echo "arm64"; fi))
	curl -fsLS -o /tmp/sessionmanagerplugin/session-manager-plugin.deb https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_$(DL_ARCH)/session-manager-plugin.deb
	sudo dpkg --install /tmp/sessionmanagerplugin/session-manager-plugin.deb
	rm -rf /tmp/sessionmanagerplugin

$(BIN_DIR)/aws-vault:
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi))
	curl -fsLS -o $(BIN_DIR)/aws-vault https://github.com/99designs/aws-vault/releases/download/v$(AWS_VALUT)/aws-vault-linux-$(DL_ARCH)
	chmod +x $(BIN_DIR)/aws-vault

$(BIN_DIR)/bat:
	mkdir -p /tmp/bat
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/bat/bat.tar.gz https://github.com/sharkdp/bat/releases/download/v$(BAT_VERSION)/bat-v$(BAT_VERSION)-$(DL_ARCH)-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/bat/bat.tar.gz -C /tmp/bat
	mv /tmp/bat/bat-v$(BAT_VERSION)-$(DL_ARCH)-unknown-linux-gnu/bat $(BIN_DIR)/bat
	mv /tmp/bat/bat-v$(BAT_VERSION)-$(DL_ARCH)-unknown-linux-gnu/autocomplete/bat.zsh $(COMPLETION_DIR)/bat.zsh
	chown `whoami`:`id -gn` $(BIN_DIR)/bat
	chown `whoami`:`id -gn` $(COMPLETION_DIR)/bat.zsh
	rm -rf /tmp/bat

$(BIN_DIR)/bun:
	curl -fsSL https://bun.sh/install | bash

$(BIN_DIR)/delta:
	mkdir -p /tmp/delta
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/delta/delta.tar.gz https://github.com/dandavison/delta/releases/download/$(DELTA_VERSION)/delta-$(DELTA_VERSION)-$(DL_ARCH)-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/delta/delta.tar.gz -C /tmp/delta
	mv /tmp/delta/delta-$(DELTA_VERSION)-$(DL_ARCH)-unknown-linux-gnu/delta $(BIN_DIR)/delta
	chown `whoami`:`id -gn` $(BIN_DIR)/delta
	rm -rf /tmp/delta

$(BIN_DIR)/dive:
	mkdir -p /tmp/dive
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi))
	curl -fsLS -o /tmp/dive/dive.tar.gz https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_$(DL_ARCH).tar.gz
	tar -zxf /tmp/dive/dive.tar.gz -C /tmp/dive
	mv /tmp/dive/dive $(BIN_DIR)/dive
	chown `whoami`:`id -gn` $(BIN_DIR)/dive
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
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/fd/fd.tar.gz https://github.com/sharkdp/fd/releases/download/v$(FD_VERSION)/fd-v$(FD_VERSION)-$(DL_ARCH)-unknown-linux-gnu.tar.gz
	tar -zxf /tmp/fd/fd.tar.gz -C /tmp/fd
	mv /tmp/fd/fd-v$(FD_VERSION)-$(DL_ARCH)-unknown-linux-gnu/fd $(BIN_DIR)/fd
	chown `whoami`:`id -gn` $(BIN_DIR)/fd
	rm -rf /tmp/fd

$(BIN_DIR)/fzf:
	mkdir -p /tmp/fzf
	curl -fsLS -o /tmp/fzf/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/v$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz
	tar -zxf /tmp/fzf/fzf.tar.gz -C /tmp/fzf
	mv /tmp/fzf/fzf $(BIN_DIR)/fzf
	chown `whoami`:`id -gn` $(BIN_DIR)/fzf
	rm -rf /tmp/fzf
	curl -fsLS -o $(BIN_DIR)/fzf-tmux https://raw.githubusercontent.com/junegunn/fzf/v${FZF_VERSION}/bin/fzf-tmux
	chmod +x $(BIN_DIR)/fzf-tmux
	curl -fsLS -o $(BIN_DIR)/fzf-key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/v${FZF_VERSION}/shell/key-bindings.zsh
	chmod +x $(BIN_DIR)/fzf-key-bindings.zsh
	curl -fsLS -o $(COMPLETION_DIR)/fzf.zsh https://raw.githubusercontent.com/junegunn/fzf/v${FZF_VERSION}/shell/completion.zsh

$(SRC_DIR)/google-cloud-sdk:
	mkdir -p /tmp/gcloud
	curl -fsLS -o /tmp/gcloud/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_VERSION}-linux-x86_64.tar.gz
	tar -zxf /tmp/gcloud/gcloud.tar.gz -C /tmp/gcloud
	mv /tmp/gcloud/google-cloud-sdk $(SRC_DIR)/google-cloud-sdk
	chown -R `whoami`:`id -gn` $(SRC_DIR)/google-cloud-sdk
	rm -rf /tmp/gcloud
	$(SRC_DIR)/google-cloud-sdk/install.sh --usage-reporting false --screen-reader true --quiet

$(BIN_DIR)/gh:
	mkdir -p /tmp/gh
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi))
	curl -fsLS -o /tmp/gh/gh.tar.gz https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_$(DL_ARCH).tar.gz
	tar -zxf /tmp/gh/gh.tar.gz -C /tmp/gh
	mv /tmp/gh/gh_${GITHUB_CLI_VERSION}_linux_$(DL_ARCH)/bin/gh $(BIN_DIR)/gh
	chown `whoami`:`id -gn` $(BIN_DIR)/gh
	rm -rf /tmp/gh

$(BIN_DIR)/ghq:
	mkdir -p /tmp/ghq
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi))
	curl -fsLS -o /tmp/ghq/ghq.zip https://github.com/x-motemen/ghq/releases/download/v$(GHQ_VERSION)/ghq_linux_$(DL_ARCH).zip
	unzip /tmp/ghq/ghq.zip -d /tmp/ghq
	mv /tmp/ghq/ghq_linux_$(DL_ARCH)/ghq $(BIN_DIR)/ghq
	rm -rf /tmp/ghq

$(COMPLETION_DIR)/git-completion.zsh:
	curl -fsLS -o $(COMPLETION_DIR)/git-completion.zsh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh

$(BIN_DIR)/jq:
	curl -fsLS -o $(BIN_DIR)/jq https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERSION)/jq-linux64
	chmod +x $(BIN_DIR)/jq

$(BIN_DIR)/navi:
	mkdir -p /tmp/navi
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	$(eval DL_LIB  := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "musl";  else echo "gnu"; fi))
	curl -fsLS -o /tmp/navi/navi.tar.gz https://github.com/denisidoro/navi/releases/download/v$(NAVI_VERSION)/navi-v$(NAVI_VERSION)-$(DL_ARCH)-unknown-linux-$(DL_LIB).tar.gz
	tar -zxf /tmp/navi/navi.tar.gz -C /tmp/navi
	mv /tmp/navi/navi $(BIN_DIR)/navi
	chown `whoami`:`id -gn` $(BIN_DIR)/navi
	rm -rf /tmp/navi

$(BIN_DIR)/rg:
	mkdir -p /tmp/rg
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	$(eval DL_LIB  := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "musl";  else echo "gnu"; fi))
	curl -fsLS -o /tmp/rg/rg.tar.gz https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-$(DL_ARCH)-unknown-linux-$(DL_LIB).tar.gz
	tar -zxf /tmp/rg/rg.tar.gz -C /tmp/rg
	mv /tmp/rg/ripgrep-$(RIPGREP_VERSION)-$(DL_ARCH)-unknown-linux-$(DL_LIB)/rg $(BIN_DIR)/rg
	chown `whoami`:`id -gn` $(BIN_DIR)/rg
	rm -rf /tmp/rg

$(BIN_DIR)/procs:
	mkdir -p /tmp/procs
	curl -fsLS -o /tmp/procs/procs.zip https://github.com/dalance/procs/releases/download/v$(PROCS_VERSION)/procs-v$(PROCS_VERSION)-x86_64-linux.zip
	unzip /tmp/procs/procs.zip -d /tmp/procs
	mv /tmp/procs/procs $(BIN_DIR)/procs
	rm -rf /tmp/procs

$(BIN_DIR)/sheldon:
	mkdir -p /tmp/sheldon
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/sheldon/sheldon.tar.gz https://github.com/rossmacarthur/sheldon/releases/download/$(SHELDON_VERSION)/sheldon-$(SHELDON_VERSION)-$(DL_ARCH)-unknown-linux-musl.tar.gz
	tar -zxf /tmp/sheldon/sheldon.tar.gz -C /tmp/sheldon
	mv /tmp/sheldon/sheldon $(BIN_DIR)/sheldon
	chown `whoami`:`id -gn` $(BIN_DIR)/sheldon
	mv /tmp/sheldon/completions/sheldon.zsh $(COMPLETION_DIR)/sheldon.zsh
	chown `whoami`:`id -gn` $(COMPLETION_DIR)/sheldon.zsh

$(BIN_DIR)/starship:
	mkdir -p /tmp/starship
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/starship/starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-$(DL_ARCH)-unknown-linux-musl.tar.gz
	tar -zxf /tmp/starship/starship.tar.gz -C /tmp/starship
	mv /tmp/starship/starship $(BIN_DIR)/starship
	chown `whoami`:`id -gn` $(BIN_DIR)/starship
	rm -rf /tmp/starship

$(BIN_DIR)/tfenv:
	git clone --depth=1 https://github.com/tfutils/tfenv.git $(HOME)/.tfenv

$(BIN_DIR)/uv:
	curl -LsSf https://astral.sh/uv/install.sh | sh

$(BIN_DIR)/yq:
	curl -fsLS -o $(BIN_DIR)/yq https://github.com/mikefarah/yq/releases/download/v$(YQ_VERSION)/yq_linux_amd64
	chmod +x $(BIN_DIR)/yq

$(BIN_DIR)/zoxide:
	mkdir -p /tmp/zoxide
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "x86_64"; else echo "aarch64"; fi))
	curl -fsLS -o /tmp/zoxide/zoxide.tar.gz https://github.com/ajeetdsouza/zoxide/releases/download/v$(ZOXIDE_VERSION)/zoxide-$(ZOXIDE_VERSION)-$(DL_ARCH)-unknown-linux-musl.tar.gz
	tar -zxf /tmp/zoxide/zoxide.tar.gz -C /tmp/zoxide
	mv /tmp/zoxide/zoxide $(BIN_DIR)/zoxide
	chown `whoami`:`id -gn` $(BIN_DIR)/zoxide
	rm -rf /tmp/zoxide

$(CARGO_BIN_DIR)/jnv:
	cargo install jnv
	rm -dfr $(CARGO_HOME)/target

$(FLUTTER_DIR)/flutter:
	mkdir -p /tmp/flutter
	curl -fsLS -o /tmp/flutter/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$(FLUTTER_VERSION)-stable.tar.xz
	tar -Jxf /tmp/flutter/flutter.tar.xz -C /tmp/flutter
	mkdir $(FLUTTER_DIR)
	mv /tmp/flutter/flutter $(FLUTTER_DIR)/
	rm -rf /tmp/flutter

$(PYENV_SHIMS_DIR)/poetry:
	pip install --quiet poetry

$(PYENV_SHIMS_DIR)/sam:
	pip install --quiet aws-sam-cli

$(PYENV_SHIMS_DIR)/pgcli:
	pip install --quiet pgcli

