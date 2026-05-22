# Agent instructions (Li compiler / `lic`)

1. Read [strict-by-default](docs/ecosystem/strict-by-default.md) — proof, security, performance **always on**; **no optional provability**.
2. Read [engineering-standards](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md) — **functionality, security, performance** (strict).
3. Read [vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — governance + milestones.
4. Read `docs/superpowers/plans/2026-05-14-li-master-plan.md` — current **PH-** phase.
5. **PR-only:** feature branch + PR; CI green; **do not self-merge** (see `.cursor/rules/li-pr-only.mdc`).
6. Synced agent-kit: `./scripts/sync-agent-kit.sh` after roadmap `agent-kit/` changes.
7. **std/** = 100% coverage; `lip publish` = ≥80%.
8. Perf status: https://li-langverse.github.io/benchmarks/
9. li-httpd: **`lis`** + [httpd prerequisites](docs/ecosystem/httpd-prerequisites.md).
10. Scalar widths / quantization: [scalar-precision.md](docs/language/scalar-precision.md) — `float4`–`float512`, suffixes (`3.14f32`), `binary` + `0b`; **no org-wide float width**; physics uses `ScalarPrecision` / `PhysicsProfile.float_bits`.
11. Precision-polymorphic APIs: [precision-polymorphism.md](docs/language/precision-polymorphism.md) — `type Real = float32` (today) and `def f[S](…)` (generics); proposed `precision float32:` block.

Skills: `strict-by-default-gate`, `build-li-master-plan`, `create-li-package`, `li-ecosystem-discipline` (in `.cursor/skills/`).

## Cursor Cloud specific instructions

### Build

```bash
cd /agent/repos/lic
LLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm CC=clang-18 CXX=clang++-18 ./scripts/build.sh
```

The update script rebuilds `lic` on startup. Binary at `build/compiler/lic/lic`.

### Running lic

The compiler resolves `runtime/li_rt.c` relative to CWD. Always run `lic build` from the repo root (`/agent/repos/lic`), not from arbitrary directories. Set `CC=clang-18` so the linker step finds the right compiler.

```bash
cd /agent/repos/lic
CC=clang-18 ./build/compiler/lic/lic build path/to/file.li -o /tmp/output
```

For IO programs, use `def main() raises IO -> int` (not `proc`). See `li-tests/effects/io_ok.li`.

### Tests

- `li-tests/run_all.sh` — full manifest (set `LI_REPO_ROOT` and `LIC` env vars)
- `li-tests/run_all.sh <suite>` — single suite
- `scripts/ci.sh` — full CI entry point (build + all gates)
- Some test failures on `main` are expected for in-development features (objects, httpd, async, SIMD, etc.)

### Lint

No separate linter binary; `scripts/check-li-def-syntax.sh` enforces `def` syntax policy.

### Lean 4

Lean/`lake` is not installed in Cloud VMs. The `lic build` command prints a warning and skips the semantics proof step. This is acceptable for non-proof work.
