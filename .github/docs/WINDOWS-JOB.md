# Windows validation job

The Windows job in `.github/workflows/validate-setup-scripts.yml` is disabled by default.

Enable it via either option:

1) Manual run (workflow_dispatch)
- In GitHub UI: Actions -> Validate setup scripts -> Run workflow
- Set the input `enableWindows` to `true`

2) Repository Actions variable (default-on)
- Settings -> Secrets and variables -> Actions -> Variables
- Create `ENABLE_WINDOWS_SETUP_VALIDATION` with value `true`

The workflow uses a small `decide-windows` job to read the dispatch input or the Actions variable
and exposes `needs.decide-windows.outputs.enabled`. The Windows job runs when that output is `true`.
