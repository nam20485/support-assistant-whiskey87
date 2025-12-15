# Testing

This document outlines the testing procedures for this repository.

## Secret Scanning with TruffleHog

This repository uses [TruffleHog](https://github.com/trufflesecurity/trufflehog) to scan for secrets in the codebase. This is enforced in CI and can be run locally.

### CI Behavior

The `.github/workflows/secret-scan-trufflehog.yml` workflow runs on every `push` and `pull_request` to the `main` branch. It will fail if it finds any verified or unknown secrets.

### Local Usage

You can run the same scan locally using the following scripts:

- **Bash:** `./scripts/security/run-trufflehog.sh`
- **PowerShell:** `./scripts/security/run-trufflehog.ps1`

### Pre-commit Hook

You can also install a pre-commit hook to automatically scan for secrets before you commit. To do so, run the following command:

```bash
git config core.hooksPath .githooks
```

### Baseline Maintenance

The `security/trufflehog-baseline.yml` file contains a baseline of all the secrets found in the repository. To regenerate this baseline, run the following command:

```bash
docker run --rm -v "$(pwd):/repo" trufflesecurity/trufflehog:latest github --repo file:///repo --only-verified > security/trufflehog-baseline.yml
```

### Allowlist

The `security/trufflehog-allowlist.yml` file contains a list of secrets that are allowed to be in the repository. You can add secrets to this file to prevent them from being flagged by TruffleHog.

### Escalation

If you find a secret in the repository, please report it to the security team immediately.
