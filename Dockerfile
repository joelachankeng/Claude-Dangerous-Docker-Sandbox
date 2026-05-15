FROM node:22-bookworm-slim

ARG TZ=Etc/UTC
ENV TZ=$TZ

# @playwright/mcp version — keep in sync with .mcp.json
ARG PLAYWRIGHT_MCP_VERSION=0.0.75

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates sudo less procps jq ripgrep nano vim \
    openssh-client gnupg dnsutils iputils-ping \
 && rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

USER node
WORKDIR /workspace

RUN mkdir -p /home/node/.npm-global /home/node/.cache/ms-playwright /home/node/.claude \
 && npm install -g @anthropic-ai/claude-code @playwright/mcp@${PLAYWRIGHT_MCP_VERSION}

USER root
RUN npx -y playwright install --with-deps chrome \
 && chown -R node:node /home/node/.cache/ms-playwright

USER node
RUN printf '%s' '{"hasCompletedOnboarding":true}' > /home/node/.claude.json \
 && printf '%s' '{"skipDangerousModePermissionPrompt":true,"enableAllProjectMcpServers":true}' > /home/node/.claude/settings.json
CMD ["bash"]
