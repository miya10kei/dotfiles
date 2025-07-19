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
