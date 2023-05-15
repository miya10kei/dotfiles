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
	brew tap homebrew/cask-fonts
	brew install --cask \
		1password \
		alt-tab \
		datagrip \
		deepl \
		docker \
		firefox \
		google-japanese-ime \
		hyper \
		karabiner-elements\
		kindle \
		miro \
		obsidian \
		rectangle \
		xquartz
