# TruffleHog Integration Plan

## Scope & Success Criteria
- Guard every push and pull request against leaked credentials using TruffleHog’s GitHub Action ([docs](https://github.com/trufflesecurity/trufflehog/tree/main)).
- Maintain automation-first compliance (≥90 % automation via GitHub Actions); limit manual steps to approvals when true positives are found.
- Ensure zero false positives reach `main` by establishing and maintaining a vetted allowlist and baseline.

## Workflow Design
- Add `.github/workflows/secret-scan-trufflehog.yml` triggered on `push`, `pull_request`, and `workflow_dispatch` events.
- Configure the job to:
  1. Checkout with event-aware `fetch-depth` so TruffleHog scans only relevant commits.
  2. Run `trufflesecurity/trufflehog@main` with `extra_args: --results=verified,unknown --fail` so the job exits with code `183` when secrets are detected.
  3. Upload scan artifacts (`results.json`, HTML summary) for auditing.
- Keep scanning event-driven; no recurring cron job is required.

## Configuration & Baseline
- Store accepted findings in YAML files:
  - `security/trufflehog-allowlist.yml`
  - `security/trufflehog-baseline.yml`
- Baseline generation command:
  ```bash
  trufflehog git file://. --results=verified,unknown --json > security/trufflehog-baseline.yml
  ```
- Pass allowlist and baseline paths to the GitHub Action via `extra_args` (for example, `--exclude-paths` or a config file when available).

## Developer Tooling
- Provide cross-platform helper scripts that mirror CI flags:
  - `scripts/security/run-trufflehog.sh`
  - `scripts/security/run-trufflehog.ps1`
- Supply pre-commit hook templates:
  - `.githooks/pre-commit-trufflehog`
  - `.githooks/pre-commit-trufflehog.ps1`
- Document how contributors enable the hooks via `git config core.hooksPath .githooks` or manual installation.

## Documentation Updates
- Extend existing documentation (for example, `docs/TESTING.md`) with:
  - When and where the workflow runs.
  - Instructions for installing and using the pre-commit hooks.
  - Procedures for updating allowlists/baselines (PR + security review required).
  - Escalation paths when a credential is verified.
- Refresh onboarding notes so new contributors can install TruffleHog locally if desired.

## Verification Plan
1. Seed a feature branch with a fake canary secret and confirm the CI workflow fails with exit code `183`.
2. Resolve the simulated finding by updating the allowlist/baseline and verify the workflow passes afterward.
3. Validate that pre-commit hooks catch staged secrets quickly.
4. Monitor runtime (<5 minutes target) and adjust checkout depth or concurrency if needed.

## Risks & Mitigations
| Risk | Mitigation |
| --- | --- |
| False positives blocking merges | Keep the allowlist tight, use `--results=verified,unknown`, and require documented escalation. |
| Long CI runtimes | Use event-aware shallow clones and targeted `--since-commit` when necessary. |
| Historical secrets in the baseline | Manually review baseline generation and treat genuine findings as incidents. |
| Action updates introducing drift | Pin the GitHub Action to a release, review changelogs quarterly, and monitor Renovate updates. |

## Acceptance Criteria
- CI workflow fails any PR introducing unapproved secrets and publishes artifacts for review.
- Allowlist and baseline YAML files reside under `security/` with clear maintenance procedures.
- Documentation explains CI behavior, hook installation, triage processes, and escalation paths.
- Developers can reproduce scans locally via scripts or hooks.
- Stakeholders approve the enforcement approach and supporting documentation.

## Next Steps (Awaiting Approval)
1. Green-light this plan.
2. Implement the CI workflow, tooling, pre-commit hooks, and documentation updates.
3. Run validation scenarios and iterate on the allowlist/baseline with the security stakeholder.

## TODO Checklist
- [x] Gather instructions and repository context.
- [x] Assess current CI for secret-scanning gaps.
- [x] Draft integration plan with risks, documentation updates, and verification steps.
- [ ] Execute the integration plan (blocked pending approval).