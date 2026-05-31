# Sprint: Li World Studio runnable on Windows + installer

**Repos:** `lic` (primary), `li` workspace (goal + launchers), `li-cursor-agents` (runtime)  
**Branch:** `cursor/world-studio-runnable-installer` (or `cursor/world-studio-master-plan-loop`)  
**Agent:** `world_studio_builder`

## Mission

Ship a **native** `li-studio-demo` that runs on Windows 10/11 (WSL or native `lic` build), with SDL present host optional, plus a **branded Inno Setup** installer (not HTML demo).

## Phase table

| Phase | Scope | Status |
|-------|-------|--------|
| **W0** | `lic` build (LLVM 22), `emit.cpp` f64→f32 `CallProc`, workspace `li-sim-sensors` | **IN PROGRESS** |
| **W1** | `li-studio-demo` build, sim tick in `studio_vertical_demo_frame`, PowerShell launcher | **IN PROGRESS** |
| **W2** | Inno Setup installer, completion gate script, sprint loop | **IN PROGRESS** |

## Progress gate

Lighter than full master plan — studio runnable slice only:

```bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
./scripts/world-studio-runnable-gate.sh
```

From repo root (`li`):

```powershell
.\scripts\start-li-world-studio.ps1 -CheckOnly
```

## Completion gate

Loop exits when **all** pass:

```bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # lic/
LIC="${LIC:-$ROOT/build-wsl/compiler/lic/lic}"
[[ -x "$LIC" ]] || LIC="$ROOT/build/compiler/lic/lic"
[[ -x "$LIC" ]] || { echo "lic binary missing"; exit 1; }
[[ -f "$ROOT/build/li-studio-demo" || -f "$ROOT/build/li-studio-demo.exe" ]] || { echo "li-studio-demo missing"; exit 1; }
"$LIC" check packages/li-studio/li-tests/smoke/studio_vertical_demo_env.li
"$LIC" check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
if command -v iscc >/dev/null 2>&1; then
  iscc /Qp installer/LiWorldStudio.iss || exit 1
else
  echo "WARN: Inno Setup (iscc) not on PATH — skip installer compile"
fi
```

## Read first

1. `lic/packages/li-studio/README.md` — build/run `li-studio-demo`
2. `lic/docs/release-notes/2026-05-30-studio-timeline-sim-tick-sync.md`
3. `lic/installer/README.md` — Inno Setup build
4. `scripts/start-li-world-studio.ps1` — Windows launcher

## Deliverables (agent)

- Green `world-studio-runnable-gate.sh` when `lic` available
- `build/li-studio-demo` (+ `.exe` on Windows)
- `installer/out/LiWorldStudio-Setup.exe` when `iscc` installed
- PR or update to [#411](https://github.com/li-langverse/lic/pull/411) with runnable + installer commits

## Environment

- **Windows:** `build-wsl/compiler/lic/lic` preferred; `LIG_HOST_PRESENT=1` needs SDL2 on PATH
- **WSL build:** `bash scripts/wsl-setup-build.sh` or existing `build-wsl/`
- **Secrets:** load `li/.env` + `li/.env.github` for `gh` (never log tokens)
