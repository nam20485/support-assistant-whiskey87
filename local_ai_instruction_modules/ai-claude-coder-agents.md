# Claude Code Subagents

This project defines a minimal set of Claude Code subagents to support targeted delegation and automation-first workflows on Windows (PowerShell/pwsh).

- Project agents live under `.claude/agents/`.
- Format: Markdown with YAML frontmatter (see files for examples).
- Shell defaults: Windows, prefer PowerShell (pwsh). Avoid bash-only commands.
- Research tasks should be delegated to the Researcher (uses gemini-mcp tools).

Quick start:
1) In VS Code with Claude Code enabled, open the Agents panel (`/agents`).
2) The project-level agents will appear; select and use them in chats.
3) Use the Orchestrator to plan, delegate to specialized agents, and approve work.

Primary references:
- `scripts/agent-creation-rules.md` (authoring guide)
- https://github.com/nam20485/agent-instructions (canonical instruction modules)

---

## Agent index

Core
- orchestrator — Plans, delegates, approves; avoids direct implementation.
- researcher — Uses gemini-mcp to research and produce citation-rich briefs.
- code-reviewer — Reviews diffs for correctness, security, performance, and style.

Build & Quality
- qa-test-engineer — Designs and runs tests; validates green builds.
- devops-engineer — CI/CD, reproducible builds, observability basics.
- frontend-developer — UI components/pages with component tests.
- backend-developer — Endpoints/modules with unit/integration tests.

Planning
- planner — Breaks work into tasks with acceptance criteria.
- product-manager — Defines goals, constraints, acceptance criteria.
- scrum-master — Facilitates cadence; removes blockers; enforces DoD.

Specialized
- cloud-infra-expert — Cloud architecture, IaC patterns, security baselines.
- github_ops_expert — Manages GitHub configuration, automation, and policy enforcement.
- performance-optimizer — Profiles and enforces performance budgets.
- security-expert — Threat modeling, secrets hygiene, dependency risk.
- database-admin — Schema/migrations, performance, backup/restore.
- data-scientist — Data pipelines, metrics, experiments, reproducibility.
- ml-engineer — Model training/inference, evaluation, deployment readiness.
- ux-ui-designer — Wireframes, flows, accessibility, design QA.
- mobile-developer — Platform-specific builds and store readiness.
- debugger — Repro steps, minimal failing tests, fix validation.
- developer — Generalist for small, scoped tasks.
- documentation-expert — Writes developer and user docs, quickstarts, and runbooks.
- prompt-engineer — System prompts, tool routing, guardrails.
