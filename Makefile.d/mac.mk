# Homebrew
.PHONY: install-homebrew
install-homebrew:
ifeq ("$(wildcard /opt/homebrew/bin/brew)", "")
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
else
	@echo "Homebrew is already installed"
endif

.PHONY: uninstall-homebrew
uninstall-homebrew:
ifeq ("$(wildcard /opt/homebrew/bin/brew)", "")
	@echo "Homebrew is not installed"
else
	NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh | bash
endif

.PHONY: brew-install
brew-install:
	brew install --cask \
		1password \
		adobe-acrobat-reader \
		alt-tab \
		aws-vpn-client \
		cursor \
		deepl \
		displaylink \
		elgato-stream-deck \
		firefox \
		ghostty \
		google-earth-pro \
		google-japanese-ime \
		homerow \
		hyper \
		karabiner-elements \
		rancher \
		raycast \
		realforce \
		rectangle \
		slack \
		visual-studio-code \
		xquartz
	brew cleanup --prune all

.PHONY: brew-update
brew-update:
	brew update \
		&& brew upgrade \
		&& brew upgrade --cask --greedy
	brew cleanup --prune all

# Rancher Desktop
.PHONY: setup-rancher
setup-rancher:
	LIMA_HOME="${HOME}/Library/Application Support/rancher-desktop/lima" \
		"/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/lima/bin/limactl" \
		shell 0 "sudo" "sed" "-i" "s/host.lima.internal$$/host.lima.internal lima-rancher-desktop/" "/etc/hosts"
