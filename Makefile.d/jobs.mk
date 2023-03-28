.PHONY: start-bg-job
start-bg-job: \
	start-denops \
	start-gopls

.PHONY: start-denops
start-denops:
	nohup deno run -A --no-lock $(HOME)/.local/share/nvim/lazy/denops.vim/denops/@denops-private/cli.ts > /dev/null 2>&1 &

.PHONY: start-gopls
start-gopls:
	nohup gopls -listen=:37374 -logfile=auto -debug=:0 > /dev/null 2>&1 &
