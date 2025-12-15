# Validation Results & Artifacts

This directory contains validation test results and logs from running the dockerized workflow agent tests.

## Directory Structure

```
validation/
├── README.md              # This file
├── results.jsonl         # JSON Lines format test results
└── logs/                 # Individual test log files
    ├── build.log         # Docker build output
    ├── sample-minimal.log # Sample workflow execution log
    └── *.log             # Other workflow execution logs
```

## Results Format

### results.jsonl

Each line is a JSON object representing a test result:

```json
{
  "timestamp": "2025-10-22T12:00:00Z",
  "test": "build_image",
  "status": "PASS",
  "duration": 45,
  "details": "Image: abc123def456, Size: 1234.5MB"
}
```

**Fields**:
- `timestamp`: ISO 8601 UTC timestamp
- `test`: Test name/identifier
- `status`: `PASS`, `FAIL`, or `SKIP`
- `duration`: Test duration in seconds
- `details`: Additional context or error information

### Log Files

Individual test logs are stored in the `logs/` directory:

- **build.log**: Complete Docker build output
- **{workflow-name}.log**: Workflow execution output (stdout/stderr combined)

## Interpreting Results

### PASS Criteria

✅ **Test Passed** if:
- Exit code is 0
- Expected output is produced
- No error messages in logs
- Meets performance expectations

### FAIL Criteria

❌ **Test Failed** if:
- Exit code is non-zero
- Expected output is missing
- Error messages in logs
- Timeout exceeded

### SKIP Criteria

⏭️ **Test Skipped** if:
- Required dependencies unavailable (e.g., API keys)
- Test is optional and conditions not met
- Explicitly marked as skipped in test suite

## Example Validation Session

### Successful Run

```jsonl
{"timestamp":"2025-10-22T12:00:00Z","test":"build_image","status":"PASS","duration":45,"details":"Image: abc123, Size: 1200MB"}
{"timestamp":"2025-10-22T12:00:45Z","test":"cli_versions","status":"PASS","duration":2,"details":"Claude: 2.0.14"}
{"timestamp":"2025-10-22T12:00:47Z","test":"auth_detection","status":"PASS","duration":1,"details":"Auth validation working"}
{"timestamp":"2025-10-22T12:00:48Z","test":"secret_masking","status":"PASS","duration":1,"details":"Secrets properly masked"}
{"timestamp":"2025-10-22T12:00:49Z","test":"debug_mode","status":"PASS","duration":2,"details":"Debug mode functional"}
{"timestamp":"2025-10-22T12:00:51Z","test":"workflow_sample-minimal","status":"PASS","duration":30,"details":"Workflow completed"}
```

**Summary**: 6/6 tests passed ✅

### Failed Run Example

```jsonl
{"timestamp":"2025-10-22T12:00:00Z","test":"build_image","status":"FAIL","duration":10,"details":"Build failed - see logs/build.log"}
```

**Action Required**: Check `logs/build.log` for detailed error information

### Skipped Test Example

```jsonl
{"timestamp":"2025-10-22T12:00:00Z","test":"workflow_sample-minimal","status":"SKIP","duration":0,"details":"No API key available"}
```

**Action Required**: Set `ANTHROPIC_API_KEY` to enable workflow execution tests

## Running Validation

### Basic Usage

```bash
# From repository root
./docker/validate.sh
```

### With API Key (for workflow tests)

```bash
export ANTHROPIC_API_KEY=sk-ant-your-key
./docker/validate.sh
```

### Reviewing Results

```bash
# View results summary
cat docker/validation/results.jsonl | jq

# Count by status
cat docker/validation/results.jsonl | jq -r '.status' | sort | uniq -c

# View failed tests
cat docker/validation/results.jsonl | jq 'select(.status == "FAIL")'

# Check build log
less docker/validation/logs/build.log

# Check workflow execution log
less docker/validation/logs/sample-minimal.log
```

## Success Metrics

### Must-Have Metrics ✅

| Metric | Target | Measurement |
|--------|--------|-------------|
| Build Success | 100% | Image builds without errors |
| CLI Availability | Claude: 100% | Claude CLI functional |
| Auth Validation | 100% | Non-interactive auth works |
| Secret Masking | 100% | No secrets in logs |
| Basic Workflow | >90% | Sample workflow executes |

### Performance Benchmarks

| Operation | Target | Acceptable |
|-----------|--------|------------|
| Image Build | <5 min | <10 min |
| Workflow Execution | <2 min | <5 min |
| Total Validation | <10 min | <20 min |

### Image Size

| Metric | Target | Acceptable |
|--------|--------|------------|
| Image Size | <1.5 GB | <2 GB |

## Troubleshooting

### Build Failures

**Check**: `logs/build.log`

Common causes:
- Base image unavailable
- Network connectivity issues
- Dockerfile syntax errors
- Missing dependencies

**Solution**:
```bash
# Manual build for debugging
docker build -t workflow-agent:debug -f docker/Dockerfile . --progress=plain
```

### Workflow Execution Failures

**Check**: `logs/{workflow-name}.log`

Common causes:
- Invalid API key
- Network connectivity to AI services
- Workflow syntax errors
- Insufficient permissions

**Solution**:
```bash
# Test workflow manually
docker run --rm \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -e WORKFLOW_NAME=sample-minimal \
  -e DEBUG=true \
  workflow-agent:validation
```

### Secret Masking Failures

**Check**: Grep logs for sensitive patterns

```bash
# Verify no secrets leaked
grep -r "sk-ant-" docker/validation/logs/
grep -r "sk-" docker/validation/logs/
```

**Critical**: If secrets found in logs, investigate immediately!

## Continuous Integration

### GitHub Actions Example

```yaml
- name: Run Validation
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: |
    ./docker/validate.sh
    
- name: Upload Validation Results
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: validation-results
    path: |
      docker/validation/results.jsonl
      docker/validation/logs/
```

## Maintenance

### Cleanup

Remove old validation artifacts:

```bash
rm -rf docker/validation/logs/*
rm -f docker/validation/results.jsonl
```

### Archiving

Archive validation results for auditing:

```bash
tar -czf validation-$(date +%Y%m%d-%H%M%S).tar.gz \
  docker/validation/results.jsonl \
  docker/validation/logs/
```

## References

- [Docker Documentation](https://docs.docker.com/)
- [JSONL Format](http://jsonlines.org/)
- [Claude CLI Documentation](https://github.com/anthropics/claude-code)

---

**Last Updated**: October 22, 2025  
**Validation Script Version**: 1.0.0
