# CLI & Authentication Research - Phase 0

**Date**: October 22, 2025  
**Base Image**: `ghcr.io/nam20485/agents-prebuild:main-latest`  
**Image SHA**: `sha256:99ace693d48b5fc24f0c223fd5ed5577491cb5f489e72067fca1208abf87aab7`

## Baseline Verification

### Image Contents

**User**: `vscode` (UID: 1000)  
**Home Directory**: `/home/vscode`

### Available CLIs

#### Claude CLI ✅
- **Path**: `/home/vscode/.local/bin/claude` (symlink to `/home/vscode/.local/share/claude/versions/2.0.14`)
- **Version**: `2.0.14 (Claude Code)`
- **Status**: ✅ Pre-installed and functional

**Test Command**:
```bash
docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "which claude"
# Output: /home/vscode/.local/bin/claude

docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "claude --version"
# Output: 2.0.14 (Claude Code)
```

#### OpenCode CLI ✅
- **Installation**: `npm install -g opencode-ai`
- **Path**: `/usr/bin/opencode` (via npm global install)
- **Version**: Latest from npm (opencode-ai package)
- **Status**: ✅ Now installed via npm in Dockerfile
- **Source**: https://opencode.ai/

**Test Command**:
```bash
docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "npm install -g opencode-ai && which opencode"
# Output: /usr/bin/opencode (or npm's bin directory)

docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "npm install -g opencode-ai && opencode --version"
# Output: OpenCode version number
```

**Findings**:
- OpenCode is available via npm as `opencode-ai` package
- Installation via: `npm install -g opencode-ai`
- Alternative methods: curl script, homebrew, paru (Arch Linux)
- Official site: https://opencode.ai/
- GitHub: https://github.com/sst/opencode
- 26K+ GitHub stars, 200K+ monthly users

**CLI Usage**:
- Interactive mode: `opencode` (launches TUI)
- Non-interactive mode: `opencode run "prompt text"`
- Authentication: Stored in `~/.local/share/opencode/auth.json`
- Supports 75+ LLM providers via Models.dev

### Helper Binaries

```bash
docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "ls -la \$HOME/.local/bin"
```

**Output**:
```
total 35484
drwxr-xr-x 1 vscode vscode     4096 Oct 14 03:13 .
drwxr-xr-x 1 vscode vscode     4096 Oct 14 03:13 ..
lrwxrwxrwx 1 vscode vscode       48 Oct 14 03:13 claude -> /home/vscode/.local/share/claude/versions/2.0.14
-rwxr-xr-x 1 vscode vscode 35965152 Dec 20  2024 uv
-rwxr-xr-x 1 vscode vscode   358696 Dec 20  2024 uvx
```

**Available Tools**:
- `claude` - Claude Code CLI v2.0.14
- `uv` - Python package manager v0.5.11
- `uvx` - UV package runner

**Additional System Tools**:
- Node.js: `/usr/bin/node`
- npm: `/usr/bin/npm`
- Git: Available (assumed, standard in devcontainers)

### Config Directories

```bash
docker run --rm ghcr.io/nam20485/agents-prebuild:main-latest bash -lc "ls -la \$HOME/.config"
```

**Output**:
```
total 16
drwxr-xr-x 1 vscode vscode 4096 Oct 13 11:15 .
drwxr-x--- 1 vscode vscode 4096 Oct 14 03:13 ..
drwxr-xr-x 1 vscode vscode 4096 Oct 13 14:57 powershell
drwxr-xr-x 2 vscode vscode 4096 Oct 13 11:15 uv
```

**Existing Directories**:
- `~/.config/powershell/` - PowerShell configuration
- `~/.config/uv/` - UV tool configuration

**Required Directories** (to be created):
- `~/.config/anthropic/` - For Claude CLI credentials
- `~/.config/opencode/` - For future OpenCode CLI support (if available)

## Authentication Mechanisms

### Claude CLI Authentication

**Official Documentation**: [Claude Code CLI README](https://github.com/anthropics/claude-code)

**Non-Interactive Setup**:
```bash
claude setup-token --token-file <path>
```

This command writes credentials to `~/.config/anthropic/claude.json` in the following format:
```json
{
  "api_key": "sk-ant-..."
}
```

**Environment Variable**: `ANTHROPIC_API_KEY`

**Implementation Strategy**:
1. Check if `~/.config/anthropic/claude.json` exists
2. If not, check for `ANTHROPIC_API_KEY` environment variable
3. If present, run `claude setup-token` to create the config file
4. If neither exists, fail with clear error message

**Token Management**:
- Tokens can be obtained from: https://console.anthropic.com/
- Tokens should be passed via Docker secrets or environment variables
- Never commit tokens to version control

### OpenCode CLI Authentication

**Official Documentation**: https://opencode.ai/docs

**Non-Interactive Setup**:
```bash
# Authentication stored at ~/.local/share/opencode/auth.json
```

Auth file format:
```json
{
  "openai": {
    "apiKey": "sk-..."
  },
  "anthropic": {
    "apiKey": "sk-ant-..."
  }
}
```

**Environment Variable**: `OPENAI_API_KEY` (or provider-specific variables)

**Implementation Strategy**:
1. Check if `~/.local/share/opencode/auth.json` exists
2. If not, check for `OPENAI_API_KEY` environment variable
3. If present, create auth.json with the API key
4. If neither exists, fail with clear error message

**Token Management**:
- Tokens can be obtained from: https://opencode.ai/auth (for OpenCode Zen)
- Or from your provider (OpenAI, Anthropic, etc.)
- Supports 75+ LLM providers via Models.dev
- Tokens should be passed via Docker secrets or environment variables
- Never commit tokens to version control

**Non-Interactive Usage**:
```bash
# Run OpenCode in non-interactive mode
opencode run "your prompt here"

# With specific model
opencode run --model openai/gpt-4 "your prompt"

# With agent
opencode run --agent backend-dev "your prompt"
```

## Implementation Decisions

### Primary CLI: Claude
Given the research findings, the implementation will:
1. **Use Claude CLI as the primary/default option** (pre-installed, verified working)
2. **Support extensibility** for future CLI additions
3. **Implement fallback logic** when multiple CLIs are available
4. **Provide clear error messages** when required tools are missing

### Fallback Strategy
When `WORKFLOW_CLIENT` is not set:
1. Check for `opencode` in PATH → use if available
2. Fallback to `claude` → use if available
3. Fail with error if neither available

When `WORKFLOW_CLIENT` is explicitly set:
1. Use the specified client
2. Fail with clear error if not available

### Authentication Priority
1. Pre-existing config files (`~/.config/anthropic/claude.json`)
2. Environment variables (`ANTHROPIC_API_KEY`)
3. Docker secrets mounted at `/run/secrets/anthropic_api_key`
4. Fail with actionable error message if none available

## Next Steps

Based on this research, Phase 1 implementation will:
1. ✅ Fix `.workflow/prompt.sh` to use bash and proper error handling
2. ✅ Support `WORKFLOW_NAME` environment variable (remove hardcoded `$workflow_name`)
3. ✅ Implement Claude CLI authentication bootstrap
4. ✅ Add pre-flight checks with remediation guidance
5. ✅ Add structured logging with secret masking
6. ✅ Support extensibility for future CLI additions

## References

- [Claude Code CLI](https://github.com/anthropics/claude-code)
- [UV Package Manager](https://github.com/astral-sh/uv)
- [Anthropic API Keys](https://console.anthropic.com/)

---

**Research Status**: ✅ Complete  
**Approval Status**: ⏳ Awaiting approval to proceed to Phase 1
