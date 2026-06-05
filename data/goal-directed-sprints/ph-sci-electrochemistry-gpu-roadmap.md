---
workflow_repo: lic
branch: cursor/ph-sci-gpu-chem-dft
plan: data/goal-directed-sprints/ph-sci-electrochemistry-gpu-roadmap.md
pr: https://github.com/li-langverse/lic/pull/847
---

# PH-SCI electrochemistry + GPU chem roadmap (combined)

**Branch:** `cursor/ph-sci-gpu-chem-dft` (PR #847)  
**Worker:** `li-ph-sci-electrochemistry` on homelab engine (`li-swarm`)

## Goal priority (one WP per iteration)

1. **[ph-sci-electrochemistry-sim-plan.md](ph-sci-electrochemistry-sim-plan.md)** — 15 WPs, easy echem P0 first  
2. **[ph-sci-gpu-chem-dft.md](ph-sci-gpu-chem-dft.md)** — CHEM vendor / LKIR parity  
3. **[ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md)** — remaining Phase 3 vendor items

## Iteration rules

1. Finish open P0 WPs in electrochemistry plan before Phase 1 AIMD/GC-DFT.  
2. One WP per loop; commit + push to `cursor/ph-sci-gpu-chem-dft`.  
3. Verify each iteration: `bash scripts/ph-sci-gpu-chem-gates.sh`.  
4. Update status tables in child plan files when WPs complete.

## Completion gate

```bash
# WSL from lic repo root
./build-wsl/compiler/lic/lic build packages/li-chem/src/lib.li --allow-open-vc
bash scripts/ph-sci-gpu-chem-gates.sh
./li-tests/run_all.sh science_gpu
test -f benchmarks/results/ph-sci-echem-competitive.json
python3 -c "import json; d=json.load(open('benchmarks/results/ph-sci-echem-competitive.json')); assert any(r.get('id')=='echem_che_h' for r in d.get('rows',[]))"
```
