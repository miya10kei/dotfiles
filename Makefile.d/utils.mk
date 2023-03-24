C := miya10kei@gmail.com

.PHONY: generate-sshkey
generate-sshkey: backup-sshkey
	ssh-keygen -t ed25519 -C ${C}

.PHONY: backup-sshkey
backup-sshkey: $(HOME)/.ssh/id_ed25519 $(HOME)/.ssh/id_ed25519.pub
	cp -f $(HOME)/.ssh/id_ed25519 $(HOME)/.ssh/id_ed25519.bk
	cp -f $(HOME)/.ssh/id_ed25519.pub $(HOME)/.ssh/id_ed25519.pub.bk
