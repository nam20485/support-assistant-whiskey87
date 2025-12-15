#!/bin/bash
#
# prompt.sh - Hardened workflow orchestration script for containerized AI agents
# Version: 2.0.0
# 
# This script serves as the Docker container entrypoint for running dynamic workflows
# with AI CLI tools (Claude, OpenCode, etc.)
#

set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure

# Configuration defaults
DEFAULT_WORKFLOW_NAME="project-setup-upgraded"
DEFAULT_CLIENT="claude"
LOG_FORMAT="json" # json or text

# Color codes for text output (disabled in JSON mode)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#
# Logging functions
#
log_json() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local container_id="${HOSTNAME:-unknown}"

    # Escape special characters for JSON
    local escaped_message=$(echo "$message" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g')

    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$escaped_message\",\"container\":\"$container_id\",\"workflow\":\"${WORKFLOW_NAME:-unknown}\"}"
}

log_text() {
    local level="$1"
    local message="$2"
    local color="$NC"
    
    case "$level" in
        ERROR) color="$RED" ;;
        WARN)  color="$YELLOW" ;;
        INFO)  color="$GREEN" ;;
    esac
    
    echo -e "${color}[$level]${NC} $message" >&2
}

log() {
    local level="$1"
    local message="$2"
    
    if [[ "$LOG_FORMAT" == "json" ]]; then
        log_json "$level" "$message"
    else
        log_text "$level" "$message"
    fi
}

mask_secret() {
    local value="$1"
    if [[ -z "$value" ]]; then
        echo "<not-set>"
    else
        local len=${#value}
        echo "<set:${len}-chars>"
    fi
}

#
# Pre-flight checks
#
check_cli_available() {
    local cli="$1"
    
    if ! command -v "$cli" &> /dev/null; then
        log "ERROR" "CLI tool '$cli' not found in PATH"
        
        if [[ "$cli" == "opencode" ]]; then
            log "ERROR" "To install OpenCode, try: uv tool install opencode (if available)"
            log "ERROR" "Alternatively, set WORKFLOW_CLIENT=claude to use Claude CLI"
        elif [[ "$cli" == "claude" ]]; then
            log "ERROR" "Claude CLI is required but not found"
            log "ERROR" "Ensure the base image includes Claude CLI or install it manually"
        fi
        
        return 1
    fi
    
    return 0
}

setup_claude_auth() {
    local config_dir="$HOME/.config/anthropic"
    local config_file="$config_dir/claude.json"
    
    # Check if config already exists
    if [[ -f "$config_file" ]]; then
        log "INFO" "Claude config found at $config_file"
        return 0
    fi
    
    # Check for API key in environment
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        # Check for Docker secret
        if [[ -f "/run/secrets/anthropic_api_key" ]]; then
            export ANTHROPIC_API_KEY=$(cat /run/secrets/anthropic_api_key)
            log "INFO" "Loaded ANTHROPIC_API_KEY from Docker secret"
        else
            log "ERROR" "ANTHROPIC_API_KEY not set and no existing config found"
            log "ERROR" "Please provide API key via environment variable or Docker secret"
            return 1
        fi
    fi
    
    # Create config directory
    printf '{\n  "api_key": "%s"\n}\n' "$ANTHROPIC_API_KEY" > "$config_file"
    
    chmod 600 "$config_file"
    log "INFO" "Created Claude config at $config_file (API key: $(mask_secret "$ANTHROPIC_API_KEY"))"
    
    return 0
}

setup_opencode_auth() {
    local auth_dir="$HOME/.local/share/opencode"
    local auth_file="$auth_dir/auth.json"
    
    # Check if auth already exists
    if [[ -f "$auth_file" ]]; then
        log "INFO" "OpenCode auth found at $auth_file"
        return 0
    fi
    
    # Check for API key in environment
    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        # Check for Docker secret
        if [[ -f "/run/secrets/openai_api_key" ]]; then
            export OPENAI_API_KEY=$(cat /run/secrets/openai_api_key)
            log "INFO" "Loaded OPENAI_API_KEY from Docker secret"
        else
            log "ERROR" "OPENAI_API_KEY not set and no existing config found"
            log "ERROR" "Please provide API key via environment variable or Docker secret"
            log "ERROR" "See https://opencode.ai/docs for authentication setup"
            return 1
        fi
    fi
    
    # Create auth directory
    mkdir -p "$auth_dir"
    
    # Write auth file in OpenCode format
    # OpenCode stores credentials at ~/.local/share/opencode/auth.json
    cat > "$auth_file" <<EOF
{
  "openai": {
    "apiKey": "$OPENAI_API_KEY"
  }
}
EOF
    
    chmod 600 "$auth_file"
    log "INFO" "Created OpenCode auth at $auth_file (API key: $(mask_secret "$OPENAI_API_KEY"))"
    
    return 0
}

#
# Main execution
#
main() {
    log "INFO" "=== Workflow Orchestration Script v2.0.0 ==="
    
    # Determine workflow name
    # Priority: WORKFLOW_NAME env var > $1 positional arg > DEFAULT
    if [[ -z "${WORKFLOW_NAME:-}" ]]; then
        if [[ $# -gt 0 ]]; then
            WORKFLOW_NAME="$1"
            shift
        else
            WORKFLOW_NAME="$DEFAULT_WORKFLOW_NAME"
        fi
    fi
    
    log "INFO" "Workflow name: $WORKFLOW_NAME"
    
    # Determine client
    # Priority: WORKFLOW_CLIENT env var > auto-detect > DEFAULT
    if [[ -z "${WORKFLOW_CLIENT:-}" ]]; then
        if command -v opencode &> /dev/null; then
            WORKFLOW_CLIENT="opencode"
            log "INFO" "Auto-detected OpenCode CLI"
        elif command -v claude &> /dev/null; then
            WORKFLOW_CLIENT="claude"
            log "INFO" "Auto-detected Claude CLI"
        else
            log "ERROR" "No supported CLI found (tried: opencode, claude)"
            exit 1
        fi
    fi
    
    log "INFO" "Using client: $WORKFLOW_CLIENT"
    
    # Pre-flight: Check CLI availability
    if ! check_cli_available "$WORKFLOW_CLIENT"; then
        exit 1
    fi
    
    # Setup authentication based on client
    case "$WORKFLOW_CLIENT" in
        claude)
            if ! setup_claude_auth; then
                exit 1
            fi
            ;;
        opencode)
            if ! setup_opencode_auth; then
                exit 1
            fi
            ;;
        *)
            log "ERROR" "Unknown client: $WORKFLOW_CLIENT"
            exit 1
            ;;
    esac
    
    # Build CLI arguments based on client
    case "$WORKFLOW_CLIENT" in
        claude)
            cli_args="--verbose --dangerously-skip-permissions "
            ;;
        opencode)
            # OpenCode uses 'run' command for non-interactive execution
            # https://opencode.ai/docs/cli
            cli_args="run"
            ;;
        *)
            cli_args=""
            ;;
    esac
    
    # Add extra arguments if provided
    if [[ -n "${EXTRA_PROMPT_ARGS:-}" ]]; then
        cli_args="$cli_args $EXTRA_PROMPT_ARGS"
        log "INFO" "Added extra args: $EXTRA_PROMPT_ARGS"
    fi
    
    # Build prompt based on client
    if [[ "$WORKFLOW_CLIENT" == "opencode" ]]; then
        # OpenCode uses positional arguments for the prompt
        prompt="perform the orchestrate-dynamic-workflow with workflow_name = '$WORKFLOW_NAME'"
    else
        # Claude uses --prompt or direct argument
        prompt="perform the orchestrate-dynamic-workflow with workflow_name = '$WORKFLOW_NAME'"
    fi
    
    # Log execution details (mask any secrets in environment)
    log "INFO" "Executing workflow..."
    log "INFO" "Command: $WORKFLOW_CLIENT $cli_args \"$prompt\""
    
    # Execute the workflow
    if [[ "${DEBUG:-false}" == "true" ]]; then
        log "INFO" "DEBUG mode: Would execute: $WORKFLOW_CLIENT $cli_args \"$prompt\""
        log "INFO" "Environment (secrets masked):"
        log "INFO" "  ANTHROPIC_API_KEY=$(mask_secret "${ANTHROPIC_API_KEY:-}")"
        log "INFO" "  OPENAI_API_KEY=$(mask_secret "${OPENAI_API_KEY:-}")"
        log "INFO" "  WORKFLOW_NAME=$WORKFLOW_NAME"
        log "INFO" "  WORKFLOW_CLIENT=$WORKFLOW_CLIENT"
        exit 0
    fi
    
    # Execute the CLI command
    $WORKFLOW_CLIENT \"$cli_args\" "$prompt"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log "INFO" "Workflow completed successfully"
    else
        log "ERROR" "Workflow failed with exit code $exit_code"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"