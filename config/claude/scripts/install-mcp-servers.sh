#!/usr/bin/env bash

set -euo pipefail

# MCPサーバを追加または更新する関数
# 既存のサーバがあれば削除してから追加する
add_or_update_mcp_server() {
    local name="$1"
    shift

    # 既存チェック
    if claude mcp get "$name" >/dev/null 2>&1; then
        echo "🗑️  Removing existing MCP server: $name"
        claude mcp remove "$name" -s user
    fi

    # 追加
    echo "➕ Adding MCP server: $name"
    claude mcp add -s user "$@"
    echo "✓ Successfully configured: $name"
    echo ""
}

# https://github.com/choplin/mcp-gemini-cli
# claude mcp add -s user gemini-cli -- npx mcp-gemini-cli --allow-npx

# https://github.com/awslabs/mcp/tree/main/src/aws-knowledge-mcp-server
add_or_update_mcp_server aws-knowledge --transport http aws-knowledge https://knowledge-mcp.global.api.aws

# https://github.com/awslabs/mcp/tree/main/src/bedrock-kb-retrieval-mcp-server
add_or_update_mcp_server bedrock-knowledge bedrock-knowledge \
  -e AWS_PROFILE=sandbox \
  -e AWS_REGION=us-east-1 \
  -e BEDROCK_KB_RERANKING_ENABLED=false \
  -e FASTMCP_LOG_LEVEL=ERROR \
  -- uvx awslabs.bedrock-kb-retrieval-mcp-server@latest

# https://github.com/github/github-mcp-server
add_or_update_mcp_server github --transport http github https://api.githubcopilot.com/mcp \
  -H "Authorization: Bearer $(pass mcp/github/pat)"

# https://support.atlassian.com/rovo/docs/setting-up-ides/
# add_or_update_mcp_server atlassian atlassian -- npx -y mcp-remote https://mcp.atlassian.com/v1/sse

# https://github.com/sooperset/mcp-atlassian
add_or_update_mcp_server atlassian atlassian \
  -e CONFLUENCE_URL=$(pass mcp/atlassian/url) \
  -e CONFLUENCE_USERNAME=$(pass mcp/atlassian/user) \
  -e CONFLUENCE_API_TOKEN=$(pass mcp/atlassian/api_key) \
  -- docker run -i --rm \
    -e CONFLUENCE_URL \
    -e CONFLUENCE_USERNAME \
    -e CONFLUENCE_API_TOKEN \
    ghcr.io/sooperset/mcp-atlassian:latest

# https://github.com/oraios/serena
add_or_update_mcp_server serena serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant

# https://github.com/upstash/context7
add_or_update_mcp_server context7 --transport http context7 https://mcp.context7.com/mcp

# https://www.npmjs.com/package/figma-developer-mcp
add_or_update_mcp_server figma-developer-mcp figma-developer-mcp \
  -e FIGMA_API_KEY=$(pass mcp/figma) \
  -- npx -y figma-developer-mcp --stdio

# https://github.com/microsoft/playwright-mcp
add_or_update_mcp_server playwright playwright -- docker run -i --rm --init --pull=always mcr.microsoft.com/playwright/mcp
