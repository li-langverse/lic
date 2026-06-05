# Electrochemistry competitive benchmark

Compare **Li `echem_che_h_adsorption_energy()`** (CHE scalar stub in `packages/li-chem/src/lib.li`) against license-friendly QM references.

## Run

```bash
# From lic repo root
pip install --user --break-system-packages -r scripts/requirements-ph-sci-chem-dft-competitive.txt
bash scripts/bench-ph-sci-echem-competitive.sh
# CI gate (install + bench + JSON + verticals.toml checks)
bash scripts/ph-sci-echem-competitive-gates.sh
```

Output: `benchmarks/results/ph-sci-echem-competitive.json`

## Methodology

| Field | Value |
|-------|-------|
| Geometry | `H 0 0 0` (H* toy until WP-ECHEM-05 slab) |
| H₂ | `H 0 0 0; H 0 0 0.74` |
| Basis | `sto-3g` |
| XC | `lda,vwn` (PySCF) |
| Li kernel | CHE formula: `E(H*) - 0.5*E(H₂) - U` with scalar stubs |
| PySCF | `dft.RKS` on H and H₂ — **primary OSS oracle** (Apache-2.0) |
| ORCA | **External manual oracle only** — not redistributable |

## Layer B registry

`benchmarks/competitive/verticals.toml` row `echem_che_h`:

- `workload_class = "pilot"` after WP-ECHEM-04 (PySCF oracle green)
- `oracle = "pyscf"`
- Large `energy_delta_ev` expected until WP-ECHEM-05 couples real slab SCF

## License notes

- **PySCF** — Apache-2.0; bundled via pip in gate script.
- **ORCA** — Academic free; **cannot** ship in CI. See [README-chem-dft.md](README-chem-dft.md).

## Files

| Path | Role |
|------|------|
| `scripts/bench-ph-sci-echem-competitive.sh` | Orchestrator + JSON merge |
| `scripts/bench-ph-sci-echem-li.sh` | Li stub timing mirror |
| `benchmarks/competitive/pyscf_echem_che_h.py` | PySCF driver |
| `benchmarks/competitive/echem_competitive_common.py` | Shared workload + Li mirror |
| `benchmarks/competitive/ph-sci-electrochemistry.toml` | Registry / tier-2 gate |
