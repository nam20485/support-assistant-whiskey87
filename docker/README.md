# Docker Workflow Agent

Dockerized AI workflow orchestration system for running dynamic workflows in isolated containers.

## Quick Start

### 1. Build the Image

```bash
cd /path/to/ai-new-app-template
docker build -t workflow-agent:latest -f docker/Dockerfile .
```

### 2. Configure Authentication

Copy the example environment file and add your API keys:

```bash
cp docker/.env.example docker/.env
# Edit docker/.env and add your ANTHROPIC_API_KEY
```

**⚠️ Security Warning**: Never commit `.env` files with real secrets!

### 3. Run a Workflow

```bash
# Using environment file
docker run --rm \
  --env-file docker/.env \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest

# Or with inline environment variables
docker run --rm \
  -e ANTHROPIC_API_KEY=sk-ant-your-key \
  -e WORKFLOW_NAME=sample-minimal \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

## Authentication Setup

### Method 1: Environment Variables (Recommended for Development)

Create `docker/.env`:

```bash
ANTHROPIC_API_KEY=sk-ant-your-api-key-here
WORKFLOW_NAME=project-setup-upgraded
WORKFLOW_CLIENT=claude
```

Run with:

```bash
docker run --rm --env-file docker/.env -v $(pwd):/workspace:ro workflow-agent:latest
```

### Method 2: Docker Secrets (Recommended for Production)

Create secrets:

```bash
echo "sk-ant-your-key" | docker secret create anthropic_api_key -
```

Run with:

```bash
docker run --rm \
  --secret anthropic_api_key \
  -e WORKFLOW_NAME=project-setup-upgraded \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

### Method 3: Pre-authenticated Config Volumes

If you have existing CLI configs, mount them:

```bash
docker run --rm \
  -v ~/.config/anthropic:/home/vscode/.config/anthropic:ro \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

## Configuration Options

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `WORKFLOW_NAME` | No | `project-setup-upgraded` | Name of workflow to execute |
| `WORKFLOW_CLIENT` | No | Auto-detect | CLI client (`claude` or `opencode`) |
| `ANTHROPIC_API_KEY` | Yes* | - | Claude API key |
| `OPENAI_API_KEY` | Yes* | - | OpenAI API key (if using OpenCode) |
| `EXTRA_PROMPT_ARGS` | No | - | Additional CLI arguments |
| `LOG_FORMAT` | No | `json` | Log format (`json` or `text`) |
| `DEBUG` | No | `false` | Enable debug mode |

\* Required unless using pre-authenticated config volumes

### Supported Workflows

See available workflows in the [agent-instructions repository](https://github.com/nam20485/agent-instructions/tree/main/ai_instruction_modules/ai-workflow-assignments/dynamic-workflows):

- `sample-minimal` - Fast test workflow
- `project-setup-upgraded` - Full project setup
- `setup-project-and-create-app` - Project + app creation
- And more...

## Usage Examples

### Run Debug Mode (Test Configuration)

```bash
docker run --rm \
  --env-file docker/.env \
  -e DEBUG=true \
  workflow-agent:latest
```

Output will show configuration without executing the workflow.

### Run Different Workflow

```bash
docker run --rm \
  --env-file docker/.env \
  -e WORKFLOW_NAME=sample-minimal \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

### Run with Text Logging

```bash
docker run --rm \
  --env-file docker/.env \
  -e LOG_FORMAT=text \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

### Run with Custom CLI Arguments

```bash
docker run --rm \
  --env-file docker/.env \
  -e EXTRA_PROMPT_ARGS="--temperature 0.8" \
  -v $(pwd):/workspace:ro \
  workflow-agent:latest
```

## Workspace Persistence

By default, the workspace is mounted **read-only** for safety:

```bash
-v $(pwd):/workspace:ro
```

For local development/testing with write access:

```bash
-v $(pwd):/workspace:rw
```

Validation outputs can be written to a dedicated volume:

```bash
docker run --rm \
  --env-file docker/.env \
  -v $(pwd):/workspace:ro \
  -v workflow-outputs:/tmp/outputs \
  workflow-agent:latest
```

## Available CLI Tools

### Claude CLI ✅

**Status**: Pre-installed in base image  
**Version**: 2.0.14 (Claude Code)  
**Path**: `/home/vscode/.local/bin/claude`  
**Auth**: `ANTHROPIC_API_KEY` or `~/.config/anthropic/claude.json`

Get API keys: https://console.anthropic.com/

### OpenCode CLI ⚠️

**Status**: Not currently available in base image  
**Installation**: TBD (installation method not yet identified)  
**Auth**: `OPENAI_API_KEY` or `~/.config/opencode/config.toml`

The script will automatically fall back to Claude if OpenCode is not available.

## Troubleshooting

### Error: "CLI tool 'claude' not found in PATH"

**Cause**: Base image doesn't include Claude CLI  
**Solution**: Verify you're using the correct base image: `ghcr.io/nam20485/agents-prebuild:main-latest`

### Error: "ANTHROPIC_API_KEY not set and no existing config found"

**Cause**: Missing authentication credentials  
**Solutions**:
1. Set `ANTHROPIC_API_KEY` in `.env` file
2. Pass via environment: `-e ANTHROPIC_API_KEY=sk-ant-...`
3. Mount existing config: `-v ~/.config/anthropic:/home/vscode/.config/anthropic:ro`
4. Use Docker secret: `--secret anthropic_api_key`

### Error: "No solution found when resolving dependencies: opencode"

**Cause**: OpenCode is not available via standard package managers  
**Solution**: Use Claude CLI instead by setting `WORKFLOW_CLIENT=claude`

### Network Errors

**Symptom**: Cannot reach raw.githubusercontent.com or AI API endpoints  
**Solutions**:
1. Check network connectivity
2. Configure proxy if needed: `-e HTTP_PROXY=...`
3. Verify firewall rules allow outbound connections

### Permission Errors

**Symptom**: Cannot write to workspace  
**Solutions**:
1. Use read-only mount for safety: `-v $(pwd):/workspace:ro`
2. For write access: `-v $(pwd):/workspace:rw`
3. Check file ownership matches container user (vscode:1000)

## Validation

To validate the dockerized agent setup, run:

```bash
docker/validate.sh
```

This will:
1. Build the image
2. Test CLI availability
3. Run sample workflows
4. Generate validation report

See [docker/validation/README.md](validation/README.md) for details.

## Advanced Topics

### Custom Base Image

To use a different base image:

```dockerfile
FROM your-custom-image:tag

# Install Claude CLI if not present
RUN curl -fsSL https://... | bash

# Rest of Dockerfile...
```

### Multi-Container Setup (Optional)

A `docker-compose.yml` is provided for convenience:

```bash
docker-compose up
```

This is optional and primarily useful for local development.

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
- name: Run Dockerized Workflow
  run: |
    docker build -t workflow-agent:${{ github.sha }} -f docker/Dockerfile .
    docker run --rm \
      -e ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }} \
      -e WORKFLOW_NAME=sample-minimal \
      -v $PWD:/workspace:ro \
      workflow-agent:${{ github.sha }}
```

## Security Best Practices

1. **Never commit API keys** - Use `.env` files in `.gitignore`
2. **Use Docker secrets** in production - More secure than environment variables
3. **Mount workspace read-only** by default - Use `:ro` flag
4. **Rotate API keys regularly** - Generate new keys periodically
5. **Scan images for vulnerabilities** - Use `docker scan workflow-agent:latest`
6. **Pin base image versions** - Use SHA instead of `:latest` tag

## References

- [Claude Code CLI Documentation](https://github.com/anthropics/claude-code)
- [Agent Instructions Repository](https://github.com/nam20485/agent-instructions)
- [Base Image](https://github.com/nam20485/agents-prebuild)
- [UV Package Manager](https://github.com/astral-sh/uv)

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review [CLI Research Document](../docs/docker/cli-research.md)
3. Open an issue in the repository
