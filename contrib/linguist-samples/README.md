# Li samples for GitHub Linguist (WP2 staging)

Real `.li` sources copied from **lic** for a future PR to [github-linguist/linguist](https://github.com/github-linguist/linguist) (`samples/Li/`). This directory is **not** submitted to linguist from lic; Julian copies into a linguist fork when WP6 opens the upstream PR.

## Contents

| File | Role |
|------|------|
| `sqrt_contract.li` | Proc contracts (`requires` / `ensures`) |
| `caller_requires_ok.li` | Caller/callee contract propagation |
| `bounds_refinement_release_ok.li` | Refinement types + array indexing |
| `http_parse_forward_closed.li` | `extern` + forwarded contracts |
| `for_range_sum.li` | `for i in start..<end` range loop |
| `matmul_2x3_ok.li` | Nested arrays + `@` matmul |
| `enum_ok.li` | `enum` types |
| `typedict_ok.li` | `typedict` + `NotRequired` |
| `tetris_main.li` | Example app (extern game loop) |
| `studio_mcp_extended.li` | Studio package smoke (`import studio`) |

Provenance and SPDX: see [SAMPLES_LICENSES.md](./SAMPLES_LICENSES.md).

## Sample selection rules

- **Real lic tree code only** — byte copies from `li-tests/`, `examples/`, or `packages/*/li-tests/`; no rewritten hello-world stubs.
- **Representative syntax** — contracts, math, collections/types, modules/imports, and at least one multi-proc example (tetris / studio).
- **No tutorial-only packs** — do not ship a directory of `hello.li` / single-line demos; classifier training needs idiomatic Li surface syntax.
- **Trim only when required** for linguist size limits; keep proc structure, contracts, and imports intact.

## Copy into linguist fork (WP6)

From a clean **lic** checkout at the commit recorded in `SAMPLES_LICENSES.md`:

```bash
LINGUIST_ROOT=/path/to/linguist   # Julian's fork, not pushed from lic CI
LIC_ROOT=/path/to/lic
COMMIT=$(git -C "$LIC_ROOT" rev-parse --short HEAD)

mkdir -p "$LINGUIST_ROOT/samples/Li"
rsync -a "$LIC_ROOT/contrib/linguist-samples/Li/" "$LINGUIST_ROOT/samples/Li/"
# Optional: record provenance in linguist PR body from SAMPLES_LICENSES.md @ $COMMIT
```

After copy, run linguist's sample tests locally (`bundle exec rake samples`) before opening the upstream PR.

## Related work

- **WP2 (this repo):** stage samples + license manifest on `feat/linguist-wp2-samples`.
- **WP6:** open linguist PR; do **not** push to `github-linguist/linguist` from lic automation.
