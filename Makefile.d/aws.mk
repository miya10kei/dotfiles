AWS_BIN_DIR := $(HOME)/.local/bin

.PHONY: install-aws
install-aws: \
	pip \
	session-manager-plugin

.PHONY: pip
pip:
	pip3 install --user \
		awscli \
		aws-mfa

.PHONY: session-manager-plugin
session-manager-plugin: /usr/local/sessionmanagerplugin
/usr/local/sessionmanagerplugin:
	mkdir -p /tmp/sessionmanagerplugin
	curl -fsLS -o /tmp/sessionmanagerplugin/session-manager-plugin.deb https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb 
	dpkg --install /tmp/sessionmanagerplugin/session-manager-plugin.deb
	rm -rf /tmp/sessionmanagerplugin
