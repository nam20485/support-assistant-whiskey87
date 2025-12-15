<#
.SYNOPSIS
    Runs TruffleHog to scan for secrets in your repository.

.DESCRIPTION
    This script is configured to match the CI workflow.

.EXAMPLE
    ./scripts/security/run-trufflehog.ps1
#>

param ()

# Get the repository root
$rootDir = git rev-parse --show-toplevel

# Run TruffleHog
docker run --rm -v "${rootDir}:/repo" trufflesecurity/trufflehog:latest git file:///repo --fail