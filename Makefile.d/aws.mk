AWS_BIN_DIR := $(HOME)/.local/bin

.PHONY: install-aws
install-aws: \
	pip \

.PHONY: pip
pip:
	pip3 install --user \
		aws-sam-cli
