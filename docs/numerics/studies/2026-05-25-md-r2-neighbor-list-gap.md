# MD neighbor cell-list gap (`md-r2-neighbor-list-gap`)

**Goal:** `md_neighbor_cell_list` (algo **105**) · **Issue:** [lic#316](https://github.com/li-langverse/lic/issues/316)  
**Agent:** `code_implementer` · **Handoff:** `sim-p1-md-neighbor-cell`  
**North star:** PH-5b (force parity before perf), PH-7e deferred until F gate green  
**Prior survey:** [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md)

---

## Problem

Registry algo **105** (`md_neighbor_cell_list`) had `implemented_smoke: true` but:

- Tier-2 `li_md_compute_forces` was O(N²) brute MIC (shared with algo 101).
- WP2 harness `#include` aliased `md_lennard_jones` oracle — no cell traversal.
- Composable `run_algo(105)` returned the generic 4-particle MD oracle checksum (not neighbor-specific).

**Honesty gap:** wiring smoke passed; physics kernel was not a cell-linked list.

---

## Phase A — Validity + wiring (complete)

| Item | Status | Evidence |
|------|--------|----------|
| Registry smoke ≠ `1.001` stub | done | `run_algo_registry_tier2.li` |
| `md_lennard_jones` brute reference | done | `benchmarks/tier2_physics/md_lennard_jones/common/md_core.h` |
| WP2 harness dir for 105 | done | `benchmarks/tier2_physics/md_neighbor_cell_list/` |
| Li vs native checksum (101) | advisory | `md_lennard_jones` tier-2 verify row |

---

## Phase B — Cell-linked list (`sim-p1-md-neighbor-cell`)

### Implementation (this slice)

1. **`md_core.h`** — half-shell cell-linked list:
   - `LiMdCellList`, `li_md_neighbor_build`, `li_md_compute_forces_cell`, `li_md_compute_forces_brute`
   - Parity helper: `li_md_force_parity_cell_vs_brute` @ N=256
   - `LI_MD_USE_CELL_LIST` compile flag for algo 105 harness

2. **`li-physics-particles`** — Pure-Li `neighbor_*` APIs @ N=16 micro:
   - `neighbor_forces_lj_brute`, `neighbor_forces_lj_cell`, `neighbor_force_parity_smoke`
   - `neighbor_oracle_checksum` for composable dispatch

3. **`li-sim-scientific`** — algo 105 routes to `run_md_neighbor_cell_smoke` (distinct checksum).

### Force parity gate

| N | Metric | Threshold | Path |
|---|--------|-----------|------|
| 256 | `max \|F_cell − F_brute\|` | `< 1e-10` | `li_md_force_parity_cell_vs_brute` in `md_core.h` |
| 16 | Pure-Li smoke | `< 1e-8` | `neighbor_force_parity_smoke.li` |

**Repro (C parity @ N=256):**

```bash
cd benchmarks/tier2_physics/md_lennard_jones
# compile parity probe against common/md_core.h (requires gcc/clang)
```

**Repro (Li smoke):**

```bash
./scripts/lit packages/li-physics-particles/li-tests/smoke/neighbor_force_parity_smoke.li
./scripts/lit packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li
```

### Deferred (post-parity)

- Algo **106** `md_neighbor_verlet_skin` — skin rebuild in `params.toml`
- PH-7e SIMD/`@vectorized` on force loop
- Dashboard ingest for `md_neighbor_cell_list` perf row

---

## Grade matrix

| Axis | Result | Notes |
|------|--------|-------|
| Validity | **pass** | F parity gate defined; cell list replaces brute alias for 105 |
| Performance | **deferred** | No `ratio_vs_cpp` until parity green on CI |
| Memory | N/A | Defer `sim-bench-memory.sh` |
| Security | pass | No new FFI; trusted C in existing `md_core` |
| Stability | partial | NVE drift unchanged; `md-r1` owns stability matrix |
| Size scaling | table in md-r0 | N=256 parity; N=4096+ after 106 skin |

---

## Tradeoffs

- **Locked:** brute reference retained; cell list must match forces exactly before perf work.
- **Improved:** algo 105 harness no longer aliases LJ oracle; composable checksum is neighbor-specific.
- **Not approved:** relaxing `threshold_ratio_cpp` or claiming PH-7e speedup pre-parity.

---

## Evidence

| Type | Path |
|------|------|
| Study | `docs/numerics/studies/2026-05-25-md-r2-neighbor-list-gap.md` |
| C kernel | `benchmarks/tier2_physics/md_lennard_jones/common/md_core.h` |
| Harness 105 | `benchmarks/tier2_physics/md_neighbor_cell_list/` |
| Pure-Li APIs | `packages/li-physics-particles/src/lib.li` |
| Dispatch | `packages/li-sim-scientific/src/lib.li` → `run_md_neighbor_cell_smoke` |
| Gates | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_STUDY_ONLY=1 SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-05-25-md-r2-neighbor-list-gap.md ./scripts/sim-algo-research-gates.sh` |
