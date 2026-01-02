ARCH := $(shell uname -m)
BIN_DIR := $(HOME)/.local/bin
SRC_DIR := $(HOME)/.local/src
COMPLETION_DIR := $(HOME)/.local/share/zsh-completion/completions

GCLOUD_VERSION := 548.0.0

.PHONY: install-bins
install-bins: \
	$(BIN_DIR) \
	$(COMPLETION_DIR) \
	$(BIN_DIR)/aws-cli \
	aws-session-manager \
	$(BIN_DIR)/claude \
	$(BIN_DIR)/coderabbit \
	$(BIN_DIR)/op \
	install-pip-packages \
	install-npm-packages \
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

$(BIN_DIR)/claude:
	curl -fsSL https://claude.ai/install.sh | bash

$(BIN_DIR)/coderabbit:
	curl -fsSL https://cli.coderabbit.ai/install.sh | sh

$(SRC_DIR)/google-cloud-sdk:
	mkdir -p /tmp/gcloud
	curl -fsLS -o /tmp/gcloud/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_VERSION}-linux-x86_64.tar.gz
	tar -zxf /tmp/gcloud/gcloud.tar.gz -C /tmp/gcloud
	mv /tmp/gcloud/google-cloud-sdk $(SRC_DIR)/google-cloud-sdk
	chown -R `whoami`:`id -gn` $(SRC_DIR)/google-cloud-sdk
	rm -rf /tmp/gcloud
	$(SRC_DIR)/google-cloud-sdk/install.sh --usage-reporting false --screen-reader true --quiet

$(BIN_DIR)/op:
	mkdir -p /tmp/op
	$(eval DL_ARCH := $(shell if [ "$(ARCH)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi))
	$(eval VERSION := $(shell curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'))
	curl -fsLS -o /tmp/op/op.zip https://cache.agilebits.com/dist/1P/op2/pkg/v$(VERSION)/op_linux_$(DL_ARCH)_v$(VERSION).zip
	unzip /tmp/op/op.zip -d /tmp/op
	mv /tmp/op/op $(BIN_DIR)/op
	rm -rf /tmp/op
	$(BIN_DIR)/op completion zsh > $(COMPLETION_DIR)/op.zsh

# Python packages (via mise)
.PHONY: install-pip-packages
install-pip-packages:
	mise exec -- pip install --quiet aws-sam-cli pgcli

# Node packages (via mise)
.PHONY: install-npm-packages
install-npm-packages:
	mise exec -- npm install -g @google/gemini-cli
