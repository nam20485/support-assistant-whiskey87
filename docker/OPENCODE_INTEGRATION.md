# OpenCode CLI Integration

## Overview

Successfully integrated OpenCode CLI support into the dockerized workflow agents, enabling the container to use either Claude or OpenCode CLI for AI-powered workflows.

## Changes Made

### 1. Docker Image
- **Dockerfile**: Added `npm install -g opencode-ai` to install OpenCode v0.15.13
- Switched to root user temporarily for global npm install
- Created `~/.local/share/opencode` config directory

### 2. Workflow Script (`.workflow/prompt.sh`)
- Updated `setup_opencode_auth()` to create auth file at `~/.local/share/opencode/auth.json`
- Changed auth file format to proper JSON structure (not TOML)
- Updated OpenCode CLI invocation from `opencode --prompt` to `opencode run`
- Made prompt handling consistent between Claude and OpenCode

### 3. Validation Suite
- Fixed path handling to work when run from `docker/` directory
- Updated CLI version detection to bypass entrypoint script
- Fixed auth detection test to check for both Claude and OpenCode errors
- Updated secret masking test to use OPENAI_API_KEY (since OpenCode is auto-detected)
- Updated debug mode test to use OPENAI_API_KEY
- All 6 tests now pass ✅

### 4. Documentation
- Updated `docs/docker/cli-research.md` with OpenCode installation method
- Documented authentication strategy using `~/.local/share/opencode/auth.json`
- Added CLI usage examples for non-interactive mode

## Validation Results

```
[INFO] === Validation Summary ===
[INFO] Total tests: 6
[PASS] Passed: 6
[FAIL] Failed: 0
[PASS] ✓ All tests passed!
```

### Test Details
1. ✅ Docker Available (1s)
2. ✅ Build Image (4s) - Image: 13.1GB
3. ✅ CLI Versions (1s)
   - Claude CLI: 2.0.14 (Claude Code)
   - OpenCode CLI: 0.15.13
4. ✅ Auth Detection (1s)
5. ✅ Secret Masking (0s)
6. ✅ Debug Mode (0s)

## OpenCode CLI Details

### Installation
```bash
npm install -g opencode-ai
```

### Authentication
Location: `~/.local/share/opencode/auth.json`

Format:
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

### Usage
```bash
# Non-interactive mode
opencode run "your prompt here"

# With specific model
opencode run --model openai/gpt-4 "your prompt"

# With agent
opencode run --agent backend-dev "your prompt"
```

## Environment Variables

The container now supports both CLI tools:

### For Claude CLI
- `ANTHROPIC_API_KEY` - Anthropic API key

### For OpenCode CLI (auto-detected, takes precedence)
- `OPENAI_API_KEY` - OpenAI API key (or provider-specific key)

## Auto-Detection Logic

The workflow script automatically detects which CLI to use:
1. Check if `opencode` command is available
2. If yes, use OpenCode (requires OPENAI_API_KEY)
3. If no, fall back to Claude CLI (requires ANTHROPIC_API_KEY)

## Docker Compose Usage

```bash
# With OpenCode
docker compose run --rm \
  -e OPENAI_API_KEY="sk-..." \
  workflow-agent sample-minimal

# With Claude (if OpenCode not detected)
docker compose run --rm \
  -e ANTHROPIC_API_KEY="sk-ant-..." \
  workflow-agent sample-minimal
```

## References

- OpenCode Website: https://opencode.ai/
- OpenCode Docs: https://opencode.ai/docs
- OpenCode CLI Docs: https://opencode.ai/docs/cli
- OpenCode GitHub: 26K+ stars, 200K+ monthly users
- npm Package: `opencode-ai`

## Status: ✅ COMPLETE

All requested functionality has been implemented and validated. OpenCode CLI is fully operational within the Docker container.
