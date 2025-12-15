# Dockerization Plan for Dynamic Workflow Agents

## Executive Summary
This plan outlines the approach to containerize the ai-new-app-template workflow agents, enabling them to run as isolated, automated agents in Docker containers directly through the hardened `.workflow/prompt.sh` runner.

## Current State Analysis

### Existing Components
- **Base Script**: `.workflow/prompt.sh` - Shell script that invokes Claude or OpenCode CLI
- **Base Image**: `ghcr.io/nam20485/agents-prebuild:main-latest` (assumed to have basic dependencies)
- **Workflow System**: Dynamic workflows resolved from remote canonical repository
- **Shell Environment**: Workspace uses bash (per environment info)

### Current Issues
1. **Script Issues**:
   - `.workflow/prompt.sh` uses `#!/bin/sh` (should be bash)
   - References undefined `$workflow_name` variable instead of the documented `WORKFLOW_NAME`
   - No error handling, validation, or observability
   - No support for environment-based configuration

2. **Authentication Challenges**:
   - Interactive authentication not suitable for containers
   - Need non-interactive auth mechanism
   - Must handle API keys/tokens securely

3. **Container Requirements**:
   - CLI tools (claude/opencode) must be available
   - Network access to AI services
   - Proper working directory context
   - Environment variable configuration

## Implementation Strategy

## Mandatory Tool Usage Protocol

This implementation MUST use the following MCP tools as mandated by the original requirements:

### Sequential Thinking Tool (`mcp_sequential-thinking_*`)
**Required Usage**:
- Before starting each implementation phase
- When encountering unexpected issues or errors
- During validation result analysis
- When making architectural decisions

**Deliverable**: Document tool usage in commit messages or validation report

### Memory Tool (`mcp_memory_*`)
**Required Storage**:
- Phase 0: CLI paths, versions, authentication mechanisms
- Phase 1: Script enhancement patterns, error handling approaches
- Phase 2: Docker configuration patterns, successful build flags
- Phase 3: Working authentication flows, secret handling patterns
- Phase 4: Validation results, success metrics, known issues

**Deliverable**: Memory entries should be retrievable for troubleshooting

### Gemini Tool (Optional)
**Recommended Use**: Large codebase analysis, conserving Claude context for implementation tasks

### Phase 0: CLI & Authentication Research
Confirm tooling expectations before touching scripts:

1. **Use Sequential Thinking**
   - Plan research approach systematically
   - Document decision rationale for CLI selection
   - Analyze base image capabilities

2. **Baseline Verification**
   - Pull `ghcr.io/nam20485/agents-prebuild:main-latest` and record the output of `bash -lc "which claude"` (currently resolves to `/home/vscode/.local/bin/claude`).
   - Capture that `opencode` is **not** preinstalled (`which opencode` exits 1) and list available helper binaries (`ls -a $HOME/.local/bin`).
   - Document default config directories exposed by the image (`$HOME/.config` includes `powershell/` and `uv/`).

3. **Auth Mechanisms**
   - For Claude COE CLI, note that `claude setup-token --token-file <path>` writes credentials to `~/.config/anthropic/claude.json` (documented in the [Claude Code CLI README](https://github.com/anthropics/claude-code)).
   - For OpenCode, plan to install via `uv tool install opencode` (ships with `uvx` in the base image) and confirm it honors the `OPENAI_API_KEY` env var stored in `~/.config/opencode/config.toml`; record the authoritative reference inside the research doc once identified.

4. **Deliverable**
   - Preserve the above in `docs/docker/cli-research.md`, including execution transcripts and pointers to official docs for both CLIs.
   - **Store findings in memory tool**: CLI paths, versions, config directories, authentication mechanisms

### Phase 1: Script Hardening
Harden `.workflow/prompt.sh` so it can operate as the direct container entrypoint:

1. **Fix Shell Compatibility**
   - Change shebang to `#!/bin/bash`
   - Add error handling (`set -e`, `set -u`, `set -o pipefail`)
   - Add validation for required environment variables

2. **Environment Configuration**
   - Support workflow name via environment variable: prefer `WORKFLOW_NAME`, fallback to positional argument, and fail fast if neither is supplied.
   - Remove the legacy `$workflow_name` usage.
   - Support authentication via environment variables:
     - `ANTHROPIC_API_KEY` for Claude (token passed to `claude setup-token --token-file` when absent)
     - `OPENAI_API_KEY` for OpenCode
   - Support debug mode: `DEBUG`
   - Default to `opencode` client when both CLIs are available, while allowing override via `WORKFLOW_CLIENT`.

3. **Enhanced Features**
   - Pre-flight checks for CLI tool availability (fail with remediation tips if `opencode` missing, instruct to run `uv tool install opencode`).
   - Structured logging (JSON lines) capturing timestamps, workflow name, client choice, and container ID when available.
   - Support for additional CLI arguments via environment (`EXTRA_PROMPT_ARGS`).
   - Guardrails to redact secrets in logs (mask values when echoing environment).
   - Document potential health check implementation as a future enhancement (explicitly out-of-scope for this iteration).

### Phase 2: Docker Configuration

1. **Dockerfile Creation** (`docker/Dockerfile`)
   ```dockerfile
   FROM ghcr.io/nam20485/agents-prebuild:main-latest

   # Install additional dependencies if needed
   # uv tool install opencode (when not already present)
   # Copy workspace files
   # Set working directory to /workspace
   # Configure entrypoint to "/workspace/.workflow/prompt.sh"
   ```

2. **Container Runtime Wiring**
   - Provide a single-container `docker compose` profile as **optional** developer convenience; default workflow uses `docker run` examples to keep scope tight.
   - Document volumes for workspace overlays (read-only by default, optional bind for local overrides).
   - Wire environment variables through `.env` files and, when available, Docker secrets mounted at `/run/secrets/*`.

3. **Supporting Files**
   - `.dockerignore` - Exclude unnecessary files
   - `docker/.env.example` - Template for environment variables with annotated defaults and secret sourcing guidance
   - `docker/README.md` - Documentation for running containers, including CLI setup notes and validation steps
   - `docs/docker/cli-research.md` - Research transcript produced in Phase 0 (lives under docs for discoverability)

### Phase 3: Authentication & Secret Handling

#### Preferred Flow (Non-interactive API keys)
- Inject `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` via environment variables sourced from Docker secrets (`docker secret create`) or an `.env` file consumed by the entrypoint.
- The entrypoint writes Claude credentials to `~/.config/anthropic/claude.json` using `claude setup-token --token-file` when the file is missing, preventing interactive prompts.
- OpenCode CLI reads `OPENAI_API_KEY`; additionally generate `~/.config/opencode/config.toml` during startup when absent to support CLI defaults.

#### Alternate Flow (Pre-authenticated volumes)
- Mount host directories containing already-initialized configs (e.g., `~/.config/anthropic` or `~/.config/opencode`) for teams unable to pass secrets through environment variables.
- Document these mounts as optional to avoid coupling to host-specific paths.

#### Contingency (Claude-only fallback)
- If OpenCode installation fails, the entrypoint will log a warning, switch `WORKFLOW_CLIENT` to `claude`, and require `ANTHROPIC_API_KEY`.
- Provide troubleshooting guidance in `docker/README.md` for retrieving new long-lived COE tokens.

**Selected Strategy**: Preferred API-key flow with explicit secret mounting guidance; other flows documented as supported alternatives.

### Phase 4: Validation & Testing

#### Validation Scripts
Create `docker/validate.sh` to orchestrate the following and emit JSON summaries to `docker/validation/results.jsonl`:
1. `docker build` succeeds (capture image tag, build duration, resulting size via `docker image inspect`).
2. Runtime pre-flight verifies both CLIs (`claude --version`, `opencode --version` after installation) and reports their paths.
3. Secrets are detected (mask length only) and config files exist without echoing values.
4. Sample workflow execution: `WORKFLOW_NAME=sample-minimal` (fast path) with `WORKFLOW_CLIENT=opencode`.
5. Fallback workflow execution: `WORKFLOW_NAME=project-setup-upgraded` with forced `WORKFLOW_CLIENT=claude` (skipped if Claude token absent, but recorded as such).

#### Evidence Collection
- Persist container stdout/stderr for each workflow under `docker/validation/logs/<workflow-name>.log`.
- Record exit codes and durations in the JSONL emit.
- Provide a short `docker/validation/README.md` summarizing how to interpret artifacts and what constitutes PASS/FAIL.

## Technical Clarifications

### Shell Environment
- **Container Shell**: bash (Linux-based container)
- **Host Shell**: pwsh (Windows host per workspace instructions)
- **Validation Scripts**: bash (run inside container)
- **Host Automation**: PowerShell (per ai-terminal-commands.md)

### GitHub Access Requirements
- Container needs `gh` CLI authenticated OR
- Container needs GitHub token via environment variable
- MCP GitHub tools must be available in container environment
- Validation must confirm GitHub operations work

### Remote Instruction Access
- Container must reach raw.githubusercontent.com
- Validation should test fetching from nam20485/agent-instructions
- Consider DNS/proxy configuration in documentation

### Runtime Dependencies
- Verify if .NET SDK needed (check workflow requirements)
- Verify if Node.js needed (check package.json usage)
- Document in Phase 0 research findings

### Workspace Persistence
- Default: read-only workspace mounts for safety
- Optional: bind mount for local development/testing
- Validation outputs written to /tmp or dedicated volume

## Acceptance Criteria

### Must Have ✅
1. **Research Delivered**
   - [ ] `docs/docker/cli-research.md` captures Phase 0 findings (CLI paths, config dirs, authentication approach) with links to official docs.

2. **Build Success**
   - [ ] Docker image builds without errors
   - [ ] Image size is reasonable (<2GB)
   - [ ] `uv tool install opencode` (or equivalent) completes and binary is on `$PATH`

3. **Script Functionality**
   - [ ] `.workflow/prompt.sh` is executable and ready for use as the container entrypoint
   - [ ] `WORKFLOW_NAME` defaults correctly (env > positional > fail) and old `$workflow_name` no longer referenced
   - [ ] Both `claude` and `opencode` clients can be selected and run within the container (with appropriate tokens)
   - [ ] Error handling prevents silent failures and logs appear in JSON lines with secrets redacted

4. **Authentication & Secrets**
   - [ ] Non-interactive authentication works for OpenCode (env + optional config templating)
   - [ ] Claude token bootstrap writes to `~/.config/anthropic/claude.json` without prompting when key provided
   - [ ] Missing credentials result in actionable error messages and non-zero exit codes

5. **Workflow Execution Evidence**
   - [ ] Validation run for `sample-minimal` succeeds with logs saved to `docker/validation/logs/sample-minimal.log`
   - [ ] Validation run for `project-setup-upgraded` executed (PASS or recorded failure reason) with exit codes captured in `docker/validation/results.jsonl`
   - [ ] `docker/validation/README.md` explains how to read artifacts and PASS/FAIL criteria

6. **Documentation**
   - [ ] README in `docker/` explains usage, authentication setup, and secret handling
   - [ ] `.env.example` documents required variables and secret sourcing patterns
   - [ ] Troubleshooting section covers missing CLI binaries, invalid tokens, and network errors

7. **Mandatory Tool Usage**
   - [ ] Sequential thinking used before each phase (evidence in logs/commits)
   - [ ] Memory tool contains research findings, CLI paths, and validation patterns
   - [ ] Tool usage documented in validation report

8. **Git Workflow**
   - [ ] Branch `docker-agents` created and pushed
   - [ ] PR opened against `main` with validation results
   - [ ] PR description includes artifact paths and success metrics

### Nice to Have 🎯 (Explicitly Deferred)
- [ ] Support for multiple concurrent agents
- [ ] Health check endpoint (documented as future enhancement, no implementation in this cycle)
- [ ] Prometheus metrics export
- [ ] Automated testing in CI/CD
- [ ] Volume mounts for persistent state

## Implementation Steps

### Step 0: Capture Research Artifacts
1. **Use sequential thinking** to plan research approach and document decision rationale.
2. Run Phase 0 commands, gather CLI presence data, and store transcripts.
3. **Store findings in memory tool** (CLI paths, versions, config directories, authentication mechanisms).
4. Draft `docs/docker/cli-research.md` with findings and doc links.
5. **Seek approval** before proceeding to Step 1.

### Step 1: Enhance prompt.sh Script
1. **Use sequential thinking** to plan script enhancements and error handling strategy.
2. Update shebang and add error handling.
3. Replace `$workflow_name` references with `WORKFLOW_NAME` handling and fallback logic.
4. Add pre-flight checks, logging, and secret masking.
5. Support additional CLI arguments via env (`WORKFLOW_CLIENT`, `EXTRA_PROMPT_ARGS`).
6. **Store successful patterns in memory tool** (error handling approaches, validation techniques).
7. Test locally before containerization.

### Step 2: Add Validation Support Scripts
1. **Use sequential thinking** to design validation strategy and success criteria.
2. Add `docker/validate.sh`, `docker/validation/README.md`, and logging directory scaffolding.
3. Implement optional `.env` loading plus Docker secrets ingestion inside `.workflow/prompt.sh` (via sourced helpers).
4. **Store validation patterns in memory tool** for future reference.

### Step 3: Create Docker Infrastructure
1. **Use sequential thinking** to plan Docker configuration and dependency management.
2. Create `docker/` directory structure and `.dockerignore`.
3. Write Dockerfile using base image, installing OpenCode via `uv tool install opencode`.
4. Provide optional `docker-compose.yml` (single service) only if it adds clarity; otherwise document `docker run` usage.
5. Create `.env.example` describing mandatory secrets and optional overrides.
6. Update `docker/README.md` with run instructions, authentication guidance, and troubleshooting.
7. **Store Docker configuration patterns in memory tool** (successful build flags, working mount strategies).

### Step 4: Testing & Validation
1. **Use sequential thinking** to analyze validation results and troubleshoot failures.
2. Build image locally.
3. Run validation script capturing artifacts.
4. Execute sample and fallback workflows, collecting logs.
5. Verify acceptance criteria and summarize outcomes.
6. **Store validation results and known issues in memory tool**.
7. Document any issues/limitations in validation report.

### Step 5: Git Workflow
1. Create branch `docker-agents`.
2. Commit all changes.
3. Push branch.
4. Create PR against `main`.
5. Include validation results and artifact paths in PR description.

## Risk Mitigation

### Risk 1: Base Image Compatibility
- **Mitigation**: Test base image has required tools; install OpenCode via `uv tool install opencode` during build if missing; capture results in research log

### Risk 2: Authentication Failures
- **Mitigation**: Implement clear error messages; provide troubleshooting guide; test both auth methods

### Risk 3: Secrets Exposure During Validation
- **Mitigation**: Mask sensitive values in logs, avoid dumping raw env vars, and validate that validation artifacts redact secrets before attaching to PRs

### Risk 4: Network Connectivity
- **Mitigation**: Add network diagnostics to validation; document proxy configuration if needed

### Risk 5: Workflow Complexity
- **Mitigation**: Start with simple workflow; gradually test more complex ones; implement timeout handling

### Risk 6: Base Image Changes
- **Mitigation**: Pin specific image tag (not just :main-latest); document current image hash in research; verify image contents in Phase 0

### Risk 7: OpenCode Installation Failure
- **Mitigation**: Detailed error logging during `uv tool install opencode`; fallback to Claude-only mode; document uv version requirements; test installation in validation

### Risk 8: Remote Workflow Unreachable
- **Mitigation**: Test network connectivity to raw.githubusercontent.com in validation; document proxy requirements; consider caching strategy for offline scenarios

## Success Metrics

1. **Container Build Time**: < 5 minutes (measured in validation logs)
2. **Workflow Execution Success Rate**: > 95% across validation runs (track in JSONL)
3. **Error Recovery**: Clear error messages for all failure modes, no silent exits
4. **Documentation Completeness**: Research doc + docker README + validation README kept in sync
5. **Secrets Hygiene**: No unmasked secrets in logs or artifacts (verified during validation)

## Timeline Estimate

- Phase 0 (Research with mandatory tools): 1-2 hours
- Phase 1 (Script Enhancement): 1-2 hours
- Phase 2 (Docker Configuration): 1-2 hours
- Phase 3 (Authentication Setup): 1 hour
- Phase 4 (Validation & Testing): 3-4 hours (increased for thorough testing)
- Buffer for unexpected issues: 1-2 hours
- **Total**: 8-13 hours

## Dependencies

### External Dependencies
- `ghcr.io/nam20485/agents-prebuild:main-latest` image must be accessible
- API keys for Claude/OpenCode must be available
- Network access to AI service endpoints

### Tool Dependencies
- Docker (>= 20.10)
- Docker Compose (>= 2.0) — optional helper for local iteration
- bash (>= 4.0)
- git
- uv (bundled with base image) for installing OpenCode CLI

## Next Steps

After plan approval:
1. Create `docker-agents` branch
2. Begin Phase 1 implementation
3. Iterative testing after each phase
4. Seek feedback before PR creation
5. Final validation before declaring success

---

## Evaluation Feedback Summary

### Review Date: 2025-10-22
### Reviewer: GitHub Copilot (using Sequential Thinking)

#### Overall Assessment: ✅ CONDITIONALLY APPROVED

**Strengths Identified**:
- Comprehensive phased approach with clear deliverables
- Strong validation strategy with measurable criteria
- Addresses authentication challenges explicitly
- Good risk mitigation framework
- Proper documentation planning

**Critical Gaps Addressed**:
1. ✅ Added Mandatory Tool Usage Protocol section
2. ✅ Added Technical Clarifications section
3. ✅ Enhanced acceptance criteria with tool usage and git workflow items
4. ✅ Updated implementation steps with tool usage checkpoints
5. ✅ Added additional risks (base image changes, OpenCode failures, remote access)
6. ✅ Increased timeline estimate to 8-13 hours with buffer

**Amendments Applied**:
- Sequential thinking and memory tool usage now mandated at each phase
- Shell environment clarifications documented (container=bash, host=pwsh)
- GitHub access requirements and runtime dependencies clarified
- Workspace persistence strategy defined
- Additional risk mitigations added
- Timeline adjusted for realistic completion with buffer

**Approval Status**: ✅ APPROVED - Ready for Phase 0 Implementation

**Next Steps**:
1. Proceed with Phase 0 (Research with mandatory tool usage)
2. Checkpoint: Present research findings and seek approval before Phase 1
3. Continue with remaining phases documenting tool usage throughout

---

**Status**: Approved (with amendments applied)
**Created**: 2025-10-21
**Updated**: 2025-10-22
**Author**: AI Agent (GitHub Copilot)
