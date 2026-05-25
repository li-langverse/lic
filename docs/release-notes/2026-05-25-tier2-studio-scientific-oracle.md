# Release notes: 2026-05-25 — tier2-studio-scientific-oracle

**Summary:** Wire tier-2 MD bench row pointer into `sim_scientific` studio step hook; stub tick until oracle built.

## Agent continuation

1. Read `packages/li-sim-scientific/src/lib.li`, `packages/li-studio/src/lib.li`.
2. Run `lic check --workspace` and tier2 smokes.
3. Then flip `tier2_md_oracle_built` when external drivers verify.
4. Blocked on LAMMPS/GROMACS CI binaries.

## Not changed

- md_core.c, SIM-2 replay, LLVM, httpd.
