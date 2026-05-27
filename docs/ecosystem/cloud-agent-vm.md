# Cloud Agent VM bootstrap (LLVM 22)

Fresh Cursor Cloud VMs must install **LLVM 22** (org pin) before `lic` builds. Older install scripts pinned **LLVM 18** and failed with `set -u` + wrong `LLVM_DIR` expansion.

## One-line install script (Cursor Cloud settings)

Point the environment **install script** at:

```bash
bash /agent/repos/lic/scripts/cloud-vm-bootstrap.sh
```

Or copy the two lines from `/tmp/cursor/async-install/install-user.sh` after syncing this repo.

## What it does

1. Runs `scripts/ci-install-llvm.sh` (LLVM **22**, clang-22, lld-22, llvm-22-dev).
2. Sources `scripts/llvm-env.sh` and writes `~/.config/environment.d/99-li-cloud.conf`.
3. Runs `./scripts/build.sh` in `lic` (skip with `LI_CLOUD_SKIP_BUILD=1`).
4. Optional: `benchmarks/dashboard` `npm ci` (skip with `LI_CLOUD_SKIP_BENCHMARKS=1`).
5. `pip3 install pytest` when available.

## Verify

```bash
source ~/.config/environment.d/99-li-cloud.conf
clang-22 --version
/agent/repos/lic/build/compiler/lic/lic --version
```

## Related

- [getting-started-tools.md](../guide/getting-started-tools.md) — LLVM 22 manual install
- [devbox-li-development.md](../guide/devbox-li-development.md) — long-lived dev machines
- `scripts/setup-li-devbox.sh` — sudo + Node for engine hosts
