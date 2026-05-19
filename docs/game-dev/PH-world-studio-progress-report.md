# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-27 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**Merge:** [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Composable gates** | **85 / 85 pass** ✅ |
| **Game dev** | **12 parse_ok** |
| **Vertical builds** | **7** |
| **Spin-up templates** | **8 compile_ok** |
| **Studio binary** | `build/bin/world-studio` + **verify script** ✅ |
| **GPU viewport** | `RenderGpuSurface` + `render_gpu_viewport_smoke` ✅ |
| **Blocked** | `sim_step_physics` (deferred) |

---

## Sprint impl-27

| Deliverable | State |
|-------------|--------|
| `RenderGpuSurface` + `render_gpu_viewport_smoke` in `li-render` | ✅ |
| `studio_bind_gpu_viewport_stub` + `studio_gpu_viewport_smoke` | ✅ |
| `studio_main.li` wires `gpu` backend + GPU viewport | ✅ |
| Composables: GPU viewport, studio GPU stack, **premerge rollup** | ✅ |
| `scripts/verify-world-studio-binary.sh` in CI | ✅ |

---

## Quick commands

```bash
./scripts/verify-world-studio-binary.sh
./scripts/check-world-studio-gates.sh
python3 -m http.server 8765 --directory deploy/studio-demo
```

---

## Composable timeline

| Sprint | Gates |
|--------|-------|
| impl-26 | 82 |
| **impl-27** | **85** |

---

## Next

1. **Merge PR** → `main`  
2. LKIR / real GPU present path in `li-gpu` + `li-render`  
3. Re-record demo reel (`./scripts/record-studio-demo.sh`)  
4. `sim_step_physics` when compiler allows cross-package types  

---

*impl-27 · `feat/world-studio-impl-1`*
