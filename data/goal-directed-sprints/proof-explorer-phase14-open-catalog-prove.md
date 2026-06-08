---
workflow_repo: lic
branch: cursor/proof-explorer-phase14-open-catalog-prove
plan: docs/superpowers/plans/proof-explorer-phase14-open-catalog-prove.md
proof_library_branch: main
---

# Proof Explorer Phase 14 — prove remaining open catalog entries

## North star

Drive **`proof_status = "open"` → `"proved"`** for every catalog row where a Li specimen + Lean discharge path exists. Do **not** stop until the phase 14 completion gate passes: **zero open catalog rows** (including Erdős register rows only when a real Lean proof exists). Keep catalog ↔ Lean scan aligned (**0 divergent**).

**Baseline (2026-06):** ~1,561 total entries; ~354 proved; ~1,109 open (~901 Erdős, ~208 non-Erdős). See `data/proof-explorer-loop/phase14-baseline.json`.

## Workspace layout (K8s / local)

- **lic** checkout: `/workspace/lic` — catalog TOML, Lean, specimens, discharge scripts.
- **proof-library**: `/workspace/proof-library` — rebuild `library.json`, PR, Pages.

```bash
export LIC_ROOT=/workspace/lic
python3 scripts/proof-db/compare_reference.py --write
python3 scripts/proof-db/proof-db.py list --status open
cd /workspace/proof-library
LIC_ROOT=/workspace/lic python3 scripts/build-library.py
bash scripts/check-library-quality.sh
python3 scripts/check-no-proc-in-library.py
```

## Iteration rules

1. Branch **`cursor/proof-explorer-phase14-open-catalog-prove`** in **lic**.
2. **Prioritize** non-Erdős open rows with existing specimens, gap scripts, or `Discharge.lean` hooks (P-linalg, P-float, P-par, physics, math lemmas).
3. For each dischargeable row:
   - Add or extend Li **`def`** specimen with `requires` / `ensures` / `implies`.
   - Wire AutoVC to **`Li.Discharge.*`** (no `Prop := True` stubs).
   - Add **`li-tests/tooling/discharge_*_lean.sh`** or extend existing gap script.
   - Retag catalog **`proof_status = "proved"`** only when discharge + gap script PASS.
4. Erdős rows: prove only with real Lean theorems; never mark **proved** while `erdos_status = "open"` without kernel discharge.
5. Rebuild proof-library; open PR; merge when CI green.
6. Append **`data/proof-explorer-loop/iteration-log.md`** each iteration.
7. Run `bash scripts/proof-explorer-gates/wp-pr-*.sh` then `bash scripts/proof-explorer-phase14-completion-gate.sh`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-PR-01 | Open-entry inventory + baseline JSON | `wp-pr-01-open-inventory.sh` |
| WP-PR-02 | Discharge tranche (≥1 open→proved per iteration when tractable rows remain) | `wp-pr-02-discharge-tranche.sh` |
| WP-PR-03 | Catalog honesty (no fake proved vs gap scripts) | `wp-pr-03-catalog-honesty.sh` |
| WP-PR-04 | proof-library rebuild + site sync | `wp-pr-04-proof-library-sync.sh` |
| WP-PR-05 | Non-Erdős open = 0 (milestone) | `wp-pr-05-non-erdos-closed.sh` |
| WP-PR-06 | All catalog open = 0 | `wp-pr-06-all-open-closed.sh` |
| WP-PR-07 | Loop state + signoff | `wp-pr-07-phase14-signoff.sh` |

## Do not

- Mark **proved** without Lean discharge + passing gap script.
- Ship `proc`, `_axiom_witness`, or placeholder `def main()` in library specimens.
- Large compiler refactors unless a gap script requires a minimal fix (human-sized scope).
- Close Erdős conjectures as proved without a real proof.

## Completion gate

```bash
bash scripts/proof-explorer-phase14-completion-gate.sh
```
