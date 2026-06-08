# Release notes: 2026-06-07 — openmptarget-offload-checklist

**Issue:** [lic#116](https://github.com/li-langverse/lic/issues/116)  
**PH / REQ:** **G-par**, **PH-7e**  
**North star fit:** scientific computing / HPC — decorator → portable offload mapping

## Summary

Adds the OpenMPTarget offload rubric under `docs/ecosystem/openmptarget-offload-checklist.md`: Li execution decorator table → host OpenMP + OpenMP target / Kokkos OpenMPTarget semantics, tier-2 physics bench scope (shared-C oracle vs future offload), and explicit **no codegen until #34** gate.

## Read first

1. `docs/ecosystem/openmptarget-offload-checklist.md`
2. Cross-links: `docs/language/decorators.md`, `docs/superpowers/specs/2026-05-16-li-execution-decorators.md`

## Tests

```bash
./scripts/check-doc-provability-claims.sh
```

## Out of scope

- LLVM OpenMP IR / `target` codegen (#34)
- Kokkos View memory-space implementation (#110)
- Tier-2 bench harness or CSV column changes
