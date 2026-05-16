# CI platforms (binding)

**Status:** Binding for `lic` CI and agents.

## Required matrix

`lic` **main** and **PR** CI must pass on **all** of:

| Job | Runner |
|-----|--------|
| `build-and-test` | `ubuntu-24.04` |
| `build-and-test-macos` | `macos-14` |
| `build-and-test-windows` | `windows-latest` |

Release and downstream dispatch depend on the **whole** CI workflow succeeding.

## Forbidden

- `continue-on-error: true` on OS build/test jobs to mask platform failures
- Dropping a platform from the matrix without a tracked issue and human approval
- “Best effort” Windows/macOS while only Linux gates merge

## When a platform fails

Fix the root cause (toolchain path, linker flags, path separators, job scripts). Use `scripts/install-llvm-windows.sh` on Windows — do not rely on Chocolatey `llvm` alone (no `LLVMConfig.cmake`).

## Related

- `.github/workflows/ci.yml`
- `.cursor/rules/li-ecosystem-gates.mdc` (CI platforms section)
- `docs/ecosystem/strict-by-default.md`
