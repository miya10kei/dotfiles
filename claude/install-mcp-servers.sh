#/usr/bin/env bash

# https://github.com/choplin/mcp-gemini-cli
# claude mcp add -s user gemini-cli -- npx mcp-gemini-cli --allow-npx

# https://github.com/awslabs/mcp/tree/main/src/aws-knowledge-mcp-server
claude mcp add -s user --transport http aws-knowledge https://knowledge-mcp.global.api.aws

# https://github.com/awslabs/mcp/tree/main/src/bedrock-kb-retrieval-mcp-server
claude mcp add -s user bedrock-knowledge \
  -e AWS_PROFILE=sandbox \
  -e AWS_REGION=us-east-1 \
  -e BEDROCK_KB_RERANKING_ENABLED=false \
  -e FASTMCP_LOG_LEVEL=ERROR \
  -- uvx awslabs.bedrock-kb-retrieval-mcp-server@latest

# https://github.com/github/github-mcp-server
claude mcp add -s user --transport http github https://api.githubcopilot.com/mcp \
  -H "Authorization: Bearer $(pass mcp/github/pat)"

# https://support.atlassian.com/rovo/docs/setting-up-ides/
claude mcp add -s user atlassian -- npx -y mcp-remote https://mcp.atlassian.com/v1/sse

# https://github.com/oraios/serena
claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant

# https://github.com/upstash/context7
claude mcp add -s user --transport http context7 https://mcp.context7.com/mcp

# https://github.com/winor30/mcp-server-datadog
claude mcp add -s user datadog \
  -e DATADOG_API_KEY=$(pass mcp/datadog/api_key) \
  -e DATADOG_APP_KEY=$(pass mcp/datadog/app_key) \
  -- npx @winor30/mcp-server-datadog \

# https://www.npmjs.com/package/figma-developer-mcp
claude mcp add -s user figma-developer-mcp \
  -e FIGMA_API_KEY=$(pass mcp/figma) \
  -- npx -y figma-developer-mcp --stdio

# https://github.com/microsoft/playwright-mcp
claude mcp add -s user playwright -- docker run -i --rm --init --pull=always mcr.microsoft.com/playwright/mcp
