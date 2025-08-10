#/usr/bin/env bash

# https://github.com/choplin/mcp-gemini-cli
claude mcp add -s user gemini-cli -- npx mcp-gemini-cli --allow-npx

# https://github.com/awslabs/mcp/tree/main/src/aws-knowledge-mcp-server
claude mcp add -s user --transport http aws-knowledge https://knowledge-mcp.global.api.aws

# https://github.com/awslabs/mcp/tree/main/src/bedrock-kb-retrieval-mcp-server
claude mcp add -s user bedrock-knowledge \
  -e AWS_PROFILE=sandbox \
  -e AWS_REGION=us-east-1 \
  -e BEDROCK_KB_RERANKING_ENABLED=false \
  -e FASTMCP_LOG_LEVEL=ERROR \
  -- uvx awslabs.bedrock-kb-retrieval-mcp-server@latest

# https://github.com/shuymn/gh-mcp
claude mcp add -s user github -- gh mcp

# https://support.atlassian.com/rovo/docs/setting-up-ides/
claude mcp add -s user atlassian -- npx -y mcp-remote https://mcp.atlassian.com/v1/sse

# https://github.com/oraios/serena
claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant

# https://github.com/upstash/context7
claude mcp add -s user --transport http context7 https://mcp.context7.com/mcp
