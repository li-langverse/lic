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

**Cloud VM:** set install script to `bash /agent/repos/lic/scripts/cloud-vm-bootstrap.sh` — [cloud-agent-vm.md](docs/ecosystem/cloud-agent-vm.md) (LLVM **22**, not 18).

## Cursor Cloud specific instructions

The workspace lives at `/workspace` (not `/agent/repos/lic`). The update script handles LLVM 22 installation, system deps, and compiler rebuild automatically on VM start.

**Building:** `./scripts/build.sh` — sources `scripts/llvm-env.sh` to auto-detect LLVM 22 cmake dir, then runs CMake + Ninja. Output binary: `./build/compiler/lic/lic`.

**Gotcha — libstdc++-14-dev:** Ubuntu 24.04 Cloud VMs may not have `libstdc++-14-dev` installed. If `clang++-22` fails to link with `cannot find -lstdc++`, run `sudo apt-get install -y libstdc++-14-dev` and retry the build.

**Running tests:**
- Full test suite: `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh`
- Single suite: `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh <suite_name>`
- Security harness: `LI_REPO_ROOT=$PWD ./li-tests/run_security.sh`
- `LI_REPO_ROOT` must be set to the repo root for tests to find the `lic` binary and std library.

**Compiling a `.li` file:** `LI_REPO_ROOT=$PWD ./build/compiler/lic/lic build file.li -o output`

**Lean 4 is optional:** The Lean verification layer (`lake`) is not installed by default. Tests and builds still pass without it; you'll see a warning: "Lean 4 / lake not installed; skipping semantics proof". Install via `scripts/ci-install-lean.sh` only if working on proof gates (PH-2f+).

**No lint tool:** There is no separate linter command. The compiler itself (`lic build` / `lic check`) performs all static analysis (types, borrow, contracts, policy). CI gates are in `scripts/ci.sh`.

**Running benchmarks:** Set `CC=clang-22 CXX=clang++-22` before running benchmarks or the execution resource sweep, since the default `clang` may not find OpenMP headers. Key commands:
- Full tier 1+2 sweep: `python3 benchmarks/harness/bench.py --tier 12 --runs 6`
- Stdlib (tier 4): `python3 benchmarks/harness/bench.py --tier 4 --runs 6`
- Registry (tier 7): `python3 benchmarks/harness/bench.py --tier 7`
- Parallel sweep: `python3 benchmarks/harness/execution_resource_sweep.py --runs 6`
- Two tier-1 benchmarks (`matmul_blocked`, `horner_pure_li`) fail Li compilation due to an LLVM IR attribute bug; exclude them with `--only` or use `--skip-verify`.
- Tier 5 ecosystem (`bench_ecosystem.py`) needs Lean 4 for the `alloc_ok.li` fixture (outcome `verify_ok`); without Lean it will fail.
- Install `time` package (`sudo apt-get install time`) for RSS measurement in execution_resource_sweep.
