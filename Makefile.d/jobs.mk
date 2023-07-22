.PHONY: start-bg-job
start-bg-job: \
	start-denops \
	start-gopls

.PHONY: starjt-denops
start-denops:
	#deno run --v8-flags=--max-old-space-size=8192 -q --no-lock --unstable -A /root/.local/share/nvim/lazy/denops.vim/denops/@denops-private/cli.ts --quiet --identity --port 32123
	deno run --v8-flags=--max-old-space-size=8192 --no-lock --unstable -A /root/.local/share/nvim/lazy/denops.vim/denops/@denops-private/cli.ts --identity --port 32123

.PHONY: start-gopls
start-gopls:
	nohup gopls -listen=:37374 -logfile=auto -debug=:0 > /dev/null 2>&1 &
