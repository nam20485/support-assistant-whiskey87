#!/bin/bash
# Usage: ./scripts/security/run-trufflehog.sh

# This script runs TruffleHog to scan for secrets in your repository.
# It's configured to match the CI workflow.

# Exit on error
set -eo pipefail

# Get the repository root
ROOT_DIR=$(git rev-parse --show-toplevel)

# Run TruffleHog
docker run --rm -v "$ROOT_DIR:/repo" trufflesecurity/trufflehog:latest git file:///repo --only-verified --fail