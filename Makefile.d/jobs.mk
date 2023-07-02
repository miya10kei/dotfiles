.PHONY: start-bg-job
start-bg-job: \
	start-denops \
	start-gopls

.PHONY: starjt-denops
start-denops:
	deno run -q --no-lock --unstable -A /root/.local/share/nvim/lazy/denops.vim/denops/@denops-private/cli.ts --quiet --identity --port 32123

.PHONY: start-gopls
start-gopls:
	nohup gopls -listen=:37374 -logfile=auto -debug=:0 > /dev/null 2>&1 &
