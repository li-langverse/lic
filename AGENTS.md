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

Skills: `strict-by-default-gate`, `build-li-master-plan`, `create-li-package`, `li-ecosystem-discipline` (in `.cursor/skills/`).

## Cursor Cloud specific instructions

### System dependencies (pre-installed on VM)

The update script installs these on every session start — no manual action needed:

- `llvm-18-dev`, `ninja-build`, `libzstd-dev`, `libstdc++-14-dev` (required for CMake/Ninja/LLVM 18 C++ builds)
- Python packages: `matplotlib`, `pandas`, `pillow` (benchmark harness)
- Node.js packages: `npm install` in `../benchmarks/dashboard/` (Vite dashboard)

### Building `lic`

```bash
cd /agent/repos/lic
export CC=clang-18 CXX=clang++-18 LLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm
./scripts/build.sh
```

The binary lands at `./build/compiler/lic/lic`. Ninja will only rebuild changed files on subsequent runs.

### Running tests

- **lic tests:** `LIC=./build/compiler/lic/lic ./li-tests/run_all.sh`
- **Full CI:** `./scripts/ci.sh` (includes build, tests, security, benchmarks, coverage)
- **lip integration:** `cd ../lip && LI_REPO=/agent/repos/lic ./scripts/lip-integration.sh`
- **lit coverage:** `cd ../lit && LI_REPO=/agent/repos/lic ./scripts/lit --version`
- **lis infra:** `cd ../lis && ./scripts/ci.sh`
- **Benchmarks dashboard:** `cd ../benchmarks/dashboard && npm run build`

### Gotchas

- `clang++-18` requires `libstdc++-14-dev` to link — it searches for gcc-14 toolchain paths. Without it, linking fails with "cannot find -lstdc++".
- `llvm-18-dev` requires `libzstd-dev` — CMake configuration fails with "target zstd::libzstd_shared not found" otherwise.
- The `li-language` repo is a parallel checkout of the language spec with its own compiler copy — it builds independently with the same CMake/LLVM setup.
- Sibling repos (`lip`, `lit`, `lis`) expect `lic` to be pre-built; set `LI_REPO=/agent/repos/lic` when running their CI scripts.
