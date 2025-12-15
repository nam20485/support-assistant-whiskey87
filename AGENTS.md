# AGENTS.md

## MCP Tools (MANDATORY for ALL agents)

- **Sequential Thinking**: ALWAYS use `mcp_sequential_thinking_*` for planning, breaking down tasks, and analyzing dependencies.
- **Memory**: ALWAYS use `mcp_memory_*` for context storage, state management, and caching patterns/conventions.
- **Gemini**: USE `mcp_gemini_*` for large codebase analysis (1M token context), conserve Claude's context window
- **Required MCP Servers**: filesystem, github, sequential-thinking, memory, gemini-cli MUST be configured

## Build/Lint/Test

- Orchestration: use your agent to orchestrate workflows per remote instructions (Claude agents only)
- Tests (.NET): `dotnet test` | single `dotnet test --filter "FullyQualifiedName~TestName"`

## Coding Style
- Formatting: Prettier/EditorConfig/trunk if present; target ~100 cols
- Naming: kebab-case files; PascalCase types/classes; camelCase vars/functions; CONSTANT_CASE constants
- Errors: fail fast; never swallow; wrap async with try/catch; surface exit codes
- Git: small focused commits; no secrets; never change git config

## Agent-Instructions & Workflows
- SSOT: use `nam20485/agent-instructions@main` via RAW URLs; see `local_ai_instruction_modules/*` indices
- Dynamic workflows: resolve by shortId from remote RAW files and orchestrate via your agent (no local script)
- Assignments: resolve by shortId from `ai-workflow-assignments.md`; follow acceptance criteria verbatim
- Tool priority: Sequential Thinking → Memory → Gemini (for large contexts) → MCP GitHub tools → VS Code → `gh` CLI; avoid GitHub web UI; scripts `./scripts/*.ps1`; .NET SDK via `global.json` (9.0.102)

## Client-specific Rules

Select and read based on which client you are.

### Copilot Rules
- `.github/copilot-instructions.md` (shell detect, RAW URLs, automation-first, web-fetch disabled → use `Invoke-WebRequest`/`curl`)

### Gemini rules
- `.gemini/GEMINI.md` (shell detect, RAW URLs, automation-first, web-fetch disabled → use `Invoke-WebRequest`/`curl`)

### Claude Code rules
- `CLAUDE.md` (shell detect, RAW URLs, automation-first, web-fetch disabled → use `Invoke-WebRequest`/`curl`)
- Use the `orchestrator` agent to run dynamic workflows. Have this agent delegate tasks to other agents as needed.

### Opencode.ai rules
- `opencode-instructions.md` (shell detect, RAW URLs, automation-first, web-fetch disabled → use `Invoke-WebRequest`/`curl`)
- Use the `orchestrator` agent to run dynamic workflows. Have this agent delegate tasks to other agents as needed.

## **IMPORTANT/CRITICAL RULES**

For all clients.

**CRITICAL**: All agents MUST use Sequential Thinking for task planning, Memory for state management, and Gemini for large-scale code analysis.
