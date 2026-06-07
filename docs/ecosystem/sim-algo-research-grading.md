# Simulation algorithm research — grading contract

**Status:** Active  
**Audience:** `numerics_researcher` / `autoresearch` in MD and chemistry vertical plan loops  
**Methodology:** [benchmarks numerics research-methodology](https://github.com/li-langverse/benchmarks/blob/main/docs/numerics/research-methodology.md)

---

## Axes

| Axis | Primary evidence | Hard gate? |
|------|------------------|------------|
| **Validity** | Tier-2 `verify-results`, composable smoke, checksum parity, registry honesty | **Yes** — todo cannot complete if fail |
| **Performance** | `bench-package.sh --timing`, ratio vs cpp/native | No — document tradeoff |
| **Memory** | `sim-bench-memory.sh` peak RSS | No — document tradeoff |
| **Security** | No new unsafe FFI; scoped `li-tests` security when touching `common/*_core.c` | Fail when native touched and security slice fails |
| **Numerical stability** | tier-0 rows, energy drift, no NaN blow-up | Tied to validity for physics kernels |
| **Size scaling** | ≥3 problem sizes in study table (N, grid, basis count) | Required in study deliverable |

**Validity is never traded** for speed or memory unless a human approves in the study doc with explicit locked axes.

---

## Tradeoff documentation (required in every study)

Each `docs/numerics/studies/YYYY-MM-DD-<slug>.md` must end with:

```markdown
## Grade matrix
| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | pass/fail | … | … |
| Performance | … | … | … |
| Memory | … | … | … |
| Security | pass/skip/N/A | … | … |
| Stability | … | … | … |
| Size scaling | table attached | … | … |

## Tradeoffs
- Locked: validity (+ stability for MD integrators)
- Improved: …
- Regressed (if any): … — justified or rejected
```

---

## Vertical scope

| Vertical | Package | Benches / smokes |
|----------|---------|------------------|
| **md** | `li-sim-scientific` | `md_lennard_jones`, `heat_equation_2d`; `md_neighbor_cell_list` when present |
| **chem** | composable + future `chem` | `import_chem_dft_smoke` when present; survey todos may pass on study-only |

---

## Enforcement

```bash
SIM_RESEARCH_VERTICAL=md|chem ./scripts/sim-algo-research-gates.sh
```

Writes `data/sim-<vertical>-research-loop/grade.json` for the live agents canvas.
