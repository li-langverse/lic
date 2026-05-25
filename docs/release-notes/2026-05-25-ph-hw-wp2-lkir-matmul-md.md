# PH-HW WP2 — LKIR matmul CPU oracle + md_force_short placeholder
**Summary:** CPU oracle matmul pilot and md_force_short placeholder in packages/lig with lig-kernels.toml pilot rows.
## Agent continuation
1. Read packages/lig/src/lib.li, runtime/li_rt_lig.c, benchmarks/competitive/lig-kernels.toml
2. Run ./scripts/bench-lig-kernel-parity.sh; lic check packages/lig
3. Then LAMMPS oracle; LIG_EMIT_* lowering
4. Blocked on vendor emit
## Changed
packages/lig, runtime/li_rt_lig.c, lig-kernels.toml, bench-lig-kernel-parity.sh
## Not changed
LIG_EMIT vendor columns; tier-2 MD oracles
## Breaking / Security / Performance / Downstream
None / N/A / local JSON / benchmarks ingest later
