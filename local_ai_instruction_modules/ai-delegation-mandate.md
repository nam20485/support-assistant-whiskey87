# Delegation Mandate Enhancement

## Overview
This document provides mandatory delegation requirements that enhance the orchestrate-dynamic-workflow assignment to force frequent delegation through explicit constraints and verification mechanisms.

## MANDATORY DELEGATION REQUIREMENTS

### Pre-Execution Rules
- **BEFORE executing ANY technical action**, the orchestrator MUST delegate to appropriate specialists
- **Maximum 3 direct actions** allowed per orchestrator (limited to: planning, coordination, approval)
- **ALL file operations, builds, tests, and infrastructure work MUST be delegated**
- **Orchestrator role**: Coordination and approval ONLY - direct execution FORBIDDEN

### Delegation Gates
- Each assignment phase **REQUIRES minimum 2 agent delegations**
- Document delegation decision matrix: Task Type → Required Agent Type
- Orchestrator must justify ANY direct execution in violation report
- **Minimum 75% delegation coverage** required for workflow success

### Agent-Task Mapping Matrix

| Task Category | Primary Agent | Secondary Agent | Justification Required |
|---------------|---------------|-----------------|----------------------|
| Repository Setup | `devops-engineer`, `github_ops_expert` | `backend-developer` | If tools unavailable |
| GitHub Operations | `github_ops_expert` | `devops-engineer` | If org-level changes required |
| Project Planning | `product-manager` | `planner` | Never |
| Code Structure | `backend-developer` | `developer` | If specialized needs |
| Documentation | `documentation-expert` | `technical-writer` | If expert unavailable |
| Testing | `qa-test-engineer` | `developer` | If QA unavailable |
| Infrastructure | `devops-engineer` | `cloud-infra-expert` | If cloud-specific |
| Security | `security-expert` | `backend-developer` | Never |
| Frontend | `frontend-developer` | `ux-ui-designer` | If UI-heavy |

### Verification Checkpoints
- **After every 2nd action**: orchestrator must report "Delegation compliance: X/Y tasks delegated"
- **Mid-workflow checkpoint**: Delegation coverage must be ≥60%
- **Final report**: Must include delegation coverage metrics
- **Workflow fails** if delegation coverage < 75%

### Delegation Decision Documentation
For each potential task, orchestrator must document:
```markdown
Task: [Description]
Agent Selected: [Agent Type]
Rationale: [Why this agent]
Alternative Considered: [Other agents evaluated]
Direct Execution Justification: [Only if not delegated - must be tool limitation]
```

## Enhanced Dynamic Workflow Syntax

### Modified Script Section
```markdown
## Script

### Delegation Requirements (MANDATORY)
Each assignment MUST be delegated to specialized agents **-OR-** broken down by task type according to section #Delegation Strategies:
- `init-existing-repository` → delegate to `devops-engineer` AND `backend-developer` AND `github_ops_expert`
- `create-app-plan` → delegate to `product-manager` AND `planner`
- `create-project-structure` → delegate to `backend-developer` AND `devops-engineer` AND `github_ops_expert`

### Delegation Strategies
1. Entire Assignment Delegation: Use Task tool to assign entire assignment to specialist agent
2. Partial Task Delegation: Break down assignment into tasks and delegate each to appropriate agents

- Choose which tasks to delegate based on agent expertise and availability
- Consider potential bottlenecks and reallocate tasks as needed
- Monitor delegated tasks and provide guidance without direct execution
- Choose delegation approach based on assignment complexity and agent capabilities

```

### Delegation Tasks (Examples) with Agent Types

| Task | Primary Agents | Supporting Agents | Notes |
| --- | --- | --- | --- |
| `init-existing-repository` | `devops-engineer`, `backend-developer` | `github_ops_expert` | Configure remotes, branches, and automation scripts. |
| `create-app-plan` | `product-manager`, `planner` | `documentation-expert` | Define roadmap, milestones, and success metrics. |
| `create-project-structure` | `backend-developer`, `devops-engineer` | `github_ops_expert`, `qa-test-engineer` | Scaffold services, CI/CD, and baseline tests. |
| `update-documentation` | `documentation-expert` | `product-manager`, `technical-writer` | Capture decisions, runbooks, and onboarding guides. |
| `expand-test-suite` | `qa-test-engineer` | `developer`, `backend-developer` | Add regression, integration, and edge-case coverage. |
| `frontend-feature` | `frontend-developer` | `ux-ui-designer`, `qa-test-engineer` | Build UI components and validate accessibility. |
| `infrastructure-hardening` | `devops-engineer` | `cloud-infra-expert`, `security-expert` | Harden pipelines, observability, and runtime guardrails. |
| `security-audit` | `security-expert` | `backend-developer`, `devops-engineer` | Review threat models, secrets hygiene, and dependency risk. |
| `data-workflow` | `data-scientist` | `ml-engineer`, `database-admin` | Design pipelines, storage strategy, and evaluation loops. |
| `performance-optimization` | `performance-optimizer` | `backend-developer`, `devops-engineer` | Profile bottlenecks and tune resource usage. |

### Execution Rules
- Orchestrator role: Coordination and approval ONLY
- Direct execution by orchestrator: FORBIDDEN except for delegation and reporting
- Minimum 2 agents per assignment phase
- Document all delegation decisions with rationale

### Assignment Execution Pattern
For each `$assignment_name` in `$assignments`, you will:
   1. **ANALYZE**: assignment requirements and identify required agent types
   2. **DELEGATE**: to appropriate specialist agent(s) using Task tool
   3. **COORDINATE**: between multiple agents if required
   4. **MONITOR**: delegated work progress and provide guidance
   5. **REVIEW**: delegated work and approve/request changes
   6. **VERIFY**: all acceptance criteria are met
   7. **RECORD**: output as `#workflow.$assignment_name`
   8. **REPORT**: delegation compliance metrics

## Enforcement Mechanisms

### Automatic Delegation Triggers
- Any mention of file creation → MUST delegate to appropriate agent
- Any build/test operation → MUST delegate to `qa-test-engineer` or `backend-developer`
- Any infrastructure setup → MUST delegate to `devops-engineer`
- Any documentation → MUST delegate to `documentation-expert`

### Violation Reporting
If direct execution occurs, orchestrator must immediately report:
```markdown
DELEGATION VIOLATION DETECTED
Task: [What was executed directly]
Reason: [Tool limitation/emergency/other]
Mitigation: [How to prevent in future]
Impact: [Effect on delegation coverage]
```

### Coverage Calculation
```markdown
Delegation Coverage = (Tasks Delegated / Total Tasks) × 100
Required Threshold: ≥75%
Target Threshold: ≥90%
```

## Integration with Orchestrator Assignment

### Enhanced Acceptance Criteria
Add to existing acceptance criteria:
8. **Delegation Coverage**: Minimum 75% of tasks delegated to specialist agents
9. **Agent Utilization**: At least 2 different agent types used per assignment
10. **Coordination Quality**: Evidence of successful agent coordination and integration

### Enhanced Run Report Schema
Add to existing Run Report:
```markdown
## Delegation Metrics
- Total Tasks: X
- Tasks Delegated: Y
- Delegation Coverage: Z%
- Agents Utilized: [List of agent types]
- Direct Execution Events: [List with justifications]
- Coordination Challenges: [Issues and resolutions]
```

## Implementation Instructions

### For Orchestrator Agents
1. **Read this document** before starting any dynamic workflow
2. **Plan delegation strategy** before executing any technical actions
3. **Use Task tool extensively** to delegate to appropriate agents
4. **Compile context** from agent instructions and workflow files to pass to agents when delegating
5. **Maintain delegation tracking** throughout execution
6. **Report delegation metrics** at checkpoints and completion

### For Dynamic Workflow Files
1. **Include delegation requirements** in Script section
2. **Specify required agent types** for each assignment
3. **Set delegation coverage targets** (minimum 75%)
4. **Document coordination requirements** between agents

### For Assignment Files
1. **Identify delegation points** in Detailed Steps
2. **Specify required agent capabilities** for each step
3. **Include delegation coverage** in Acceptance Criteria
4. **Document coordination handoffs** between agents

### Context Compilation for Delegation
When delegating tasks, compile and provide the following context to the delegated agent:
- **Assignment Overview**: Brief summary of the overall assignment and its objectives.
- **Specific Task Details**: Clear description of the specific task being delegated, including any relevant requirements or constraints.
- **Related Instructions**: Relevant sections from the agent instructions that pertain to the task.
- **Workflow Context**: Information about the current state of the workflow, including any dependencies or prior steps that impact the task.
- **Acceptance Criteria**: The specific criteria that must be met for the task to be considered complete.
- **Tools and Resources**: Any specific tools, repositories, or resources that the agent will need to complete the task.
- **Communication Protocols**: Preferred methods for updates, questions, and reporting progress.

## Monitoring and Compliance

### Real-Time Tracking
- Track delegation decisions as they occur
- Calculate running delegation coverage percentage
- Alert when coverage drops below thresholds
- Document all direct execution with justification

### Post-Execution Review
- Analyze delegation effectiveness
- Identify improvement opportunities
- Update agent-task mapping based on results
- Refine delegation strategies for future workflows

This delegation mandate ensures that orchestrator agents primarily focus on coordination and oversight while leveraging specialist agents for technical execution, leading to more distributed and specialized workflow execution.
