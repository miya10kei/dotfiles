.PHONY: start-bg-job
start-bg-job: \
	start-gopls

.PHONY: start-gopls
start-gopls:
	nohup gopls -listen=:37374 -logfile=auto -debug=:0 > /dev/null 2>&1 &
