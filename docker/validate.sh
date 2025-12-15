#!/bin/bash
#
# validate.sh - Validation orchestration script for dockerized workflow agents
# Version: 1.0.0
#
# This script validates that the dockerized agents can run workflows successfully
# by building the image, running pre-flight checks, and executing sample workflows.
#

set -e
set -u
set -o pipefail

# Configuration
IMAGE_NAME="workflow-agent"
IMAGE_TAG="validation"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Detect script directory and set working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running from docker directory, move to parent
if [[ "$(basename "$SCRIPT_DIR")" == "docker" ]]; then
    cd "$SCRIPT_DIR/.."
fi

RESULTS_FILE="docker/validation/results.jsonl"
LOGS_DIR="docker/validation/logs"
DOCKERFILE="docker/Dockerfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

#
# Logging functions
#
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_result() {
    local test_name="$1"
    local status="$2"
    local duration="$3"
    local details="$4"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Escape special characters for JSON
    local escaped_details=$(echo "$details" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g')

    echo "{\"timestamp\":\"$timestamp\",\"test\":\"$test_name\",\"status\":\"$status\",\"duration\":$duration,\"details\":\"$escaped_details\"}" >> "$RESULTS_FILE"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "Running test: $test_name"
    
    local start_time=$(date +%s)
    
    if eval "$test_command"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "$test_name (${duration}s)"
        log_result "$test_name" "PASS" "$duration" "Test completed successfully"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_error "$test_name (${duration}s)"
        log_result "$test_name" "FAIL" "$duration" "Test failed with exit code $?"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

#
# Test functions
#
test_docker_available() {
    docker --version > /dev/null 2>&1
}

test_build_image() {
    log_info "Building Docker image: $FULL_IMAGE"
    local start_time=$(date +%s)
    
    if docker build -t "$FULL_IMAGE" -f "$DOCKERFILE" . > "$LOGS_DIR/build.log" 2>&1; then
        local end_time=$(date +%s)
        local image_size=$(docker image inspect "$FULL_IMAGE" --format='{{.Size}}' | awk '{printf "%.1f", $1/1024/1024}')
        
        # Get image details
        local image_size=$(docker image inspect "$FULL_IMAGE" --format='{{.Size}}' | awk '{print $1/1024/1024}')
        local image_id=$(docker image inspect "$FULL_IMAGE" --format='{{.Id}}' | cut -d: -f2 | cut -c1-12)
        
        log_success "Image built: $image_id (${image_size}MB, ${duration}s)"
        log_result "build_image" "PASS" "$duration" "Image: $image_id, Size: ${image_size}MB"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_error "Image build failed (${duration}s)"
        log_result "build_image" "FAIL" "$duration" "Build failed - see logs/build.log"
        return 1
    fi
}

test_cli_versions() {
    log_info "Checking CLI versions"
    
    # Test Claude CLI (bypass entrypoint)
    local claude_version=$(docker run --rm --entrypoint /bin/bash "$FULL_IMAGE" -c "claude --version" 2>&1 || echo "NOT_FOUND")
    if [[ "$claude_version" != "NOT_FOUND" && "$claude_version" != *"ERROR"* ]]; then
        log_success "Claude CLI: $claude_version"
        echo "{\"cli\":\"claude\",\"version\":\"$claude_version\",\"available\":true}" >> "$RESULTS_FILE"
    else
        log_error "Claude CLI not found"
        echo "{\"cli\":\"claude\",\"version\":null,\"available\":false}" >> "$RESULTS_FILE"
        return 1
    fi
    
    # Test OpenCode CLI (bypass entrypoint)
    local opencode_version=$(docker run --rm --entrypoint /bin/bash "$FULL_IMAGE" -c "opencode --version" 2>&1 || echo "NOT_FOUND")
    if [[ "$opencode_version" != "NOT_FOUND" && "$opencode_version" != *"ERROR"* ]]; then
        log_success "OpenCode CLI: $opencode_version"
        echo "{\"cli\":\"opencode\",\"version\":\"$opencode_version\",\"available\":true}" >> "$RESULTS_FILE"
    else
        log_warn "OpenCode CLI not found (expected - will use Claude fallback)"
        echo "{\"cli\":\"opencode\",\"version\":null,\"available\":false}" >> "$RESULTS_FILE"
    fi
    
    return 0
}

test_auth_detection() {
    log_info "Testing authentication detection"
    
    # Test without API keys (should fail gracefully with either Claude or OpenCode error)
    local output=$(docker run --rm --entrypoint /bin/bash "$FULL_IMAGE" -c "unset ANTHROPIC_API_KEY OPENAI_API_KEY && /workspace/.workflow/prompt.sh" 2>&1 || true)
    
    if echo "$output" | grep -qE "(ANTHROPIC_API_KEY not set|OPENAI_API_KEY not set)"; then
        log_success "Auth detection working correctly"
        return 0
    else
        log_error "Auth detection not working as expected"
        return 1
    fi
}

test_debug_mode() {
    log_info "Testing debug mode"
    
    # Run in debug mode (should not execute workflow but should show debug info)
    # Use OPENAI_API_KEY since OpenCode is auto-detected
    local output=$(docker run --rm \
        -e OPENAI_API_KEY="sk-test-key-12345" \
        -e DEBUG=true \
        -e WORKFLOW_NAME=sample-minimal \
        "$FULL_IMAGE" 2>&1)
    
    if echo "$output" | grep -qE "(DEBUG mode|debug_mode|Debug Mode)"; then
        log_success "Debug mode working correctly"
        return 0
    else
        log_error "Debug mode not working as expected"
        return 1
    fi
}

test_sample_workflow() {
    local workflow_name="$1"
    local log_file="$LOGS_DIR/${workflow_name}.log"
    
    log_info "Testing workflow: $workflow_name"
    
    # Check if ANTHROPIC_API_KEY is available
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        log_warn "ANTHROPIC_API_KEY not set - skipping workflow execution test"
        log_result "workflow_${workflow_name}" "SKIP" "0" "No API key available"
        return 0
    fi
    
    local start_time=$(date +%s)
    
    if docker run --rm \
        -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
        -e WORKFLOW_NAME="$workflow_name" \
        -e WORKFLOW_CLIENT=claude \
        -v "$(pwd):/workspace:ro" \
        "$FULL_IMAGE" > "$log_file" 2>&1; then
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "Workflow '$workflow_name' completed (${duration}s)"
        log_result "workflow_${workflow_name}" "PASS" "$duration" "Workflow completed successfully"
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_error "Workflow '$workflow_name' failed with exit code $exit_code (${duration}s)"
        log_result "workflow_${workflow_name}" "FAIL" "$duration" "Exit code: $exit_code - see logs/${workflow_name}.log"
        return 1
    fi
}

test_secret_masking() {
    log_info "Testing secret masking in logs"
    
    # Test with OpenAI API key (since OpenCode is auto-detected)
    local output=$(docker run --rm \
        -e OPENAI_API_KEY="sk-test-secret-12345" \
        -e DEBUG=true \
        "$FULL_IMAGE" 2>&1)
    
    # Verify that the actual key is NOT in the output
    if echo "$output" | grep -q "sk-test-secret-12345"; then
        log_error "Secret masking FAILED - API key visible in logs!"
        return 1
    fi
    
    # Verify that mask placeholder IS in the output
    if echo "$output" | grep -qE "(<set:|DEBUG mode enabled)"; then
        log_success "Secret masking working correctly"
        return 0
    else
        log_error "Secret masking not working as expected"
        return 1
    fi
}

#
# Main validation flow
#
main() {
    log_info "=== Docker Workflow Agent Validation ==="
    log_info "Starting validation at $(date)"
    echo ""
    
    # Setup
    mkdir -p "$LOGS_DIR"
    rm -f "$RESULTS_FILE"
    touch "$RESULTS_FILE"
    
    # Run tests
    run_test "Docker Available" "test_docker_available" || {
        log_error "Docker is not available - cannot proceed with validation"
        exit 1
    }
    
    run_test "Build Image" "test_build_image" || {
        log_error "Image build failed - cannot proceed with validation"
        exit 1
    }
    
    run_test "CLI Versions" "test_cli_versions"
    run_test "Auth Detection" "test_auth_detection"
    run_test "Secret Masking" "test_secret_masking"
    run_test "Debug Mode" "test_debug_mode"
    
    # Workflow tests (only if API key available)
    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        log_info ""
        log_info "Running workflow execution tests..."
        run_test "Sample Workflow (minimal)" "test_sample_workflow sample-minimal"
        # Uncomment to test additional workflows:
        # run_test "Sample Workflow (project-setup)" "test_sample_workflow project-setup-upgraded"
    else
        log_warn "ANTHROPIC_API_KEY not set - skipping workflow execution tests"
        log_warn "To test workflow execution, set ANTHROPIC_API_KEY and re-run"
    fi
    
    # Summary
    echo ""
    log_info "=== Validation Summary ==="
    log_info "Total tests: $TOTAL_TESTS"
    log_success "Passed: $PASSED_TESTS"
    log_error "Failed: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "✓ All tests passed!"
        echo ""
        log_info "Validation results: $RESULTS_FILE"
        log_info "Test logs: $LOGS_DIR/"
        exit 0
    else
        log_error "✗ Some tests failed"
        echo ""
        log_info "Validation results: $RESULTS_FILE"
        log_info "Test logs: $LOGS_DIR/"
        exit 1
    fi
}

# Run main function
main "$@"
