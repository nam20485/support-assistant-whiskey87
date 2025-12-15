# Dockerfile for AI Workflow Agents
# Base: ghcr.io/nam20485/agents-prebuild:main-latest
# Includes: Claude CLI, UV, Node.js, Git

FROM ghcr.io/nam20485/agents-prebuild:main-latest

# Metadata
LABEL org.opencontainers.image.title="AI New App Template - Dockerized Workflow Agent"
LABEL org.opencontainers.image.description="Containerized AI workflow orchestration with Claude CLI"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="nam20485"

USER root

# Set working directory
RUN mkdir /workspace

# Copy workspace files
# Note: We copy everything except what's in .dockerignore
COPY . /workspace/

RUN ls -la /workspace/.workflow/

# Make prompt script executable (if it exists)
RUN chmod +x /workspace/.workflow/prompt.sh

# Install OpenCode CLI via npm
# https://opencode.ai/docs
# Need to switch to root to install globally
USER root
RUN npm install -g opencode-ai
USER vscode

# Create necessary config directories
RUN mkdir -p \
    /home/vscode/.config/anthropic \
    /home/vscode/.local/share/opencode

# Set environment defaults
ENV WORKFLOW_NAME="project-setup-upgraded"
ENV LOG_FORMAT="json"
ENV DEBUG="false"

# Health check (future enhancement - currently commented out)
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#   CMD test -f /tmp/workflow.lock || exit 1

# Set entrypoint to the hardened prompt script
ENTRYPOINT ["/workspace/.workflow/prompt.sh"]

# Default command (can be overridden)
CMD []
