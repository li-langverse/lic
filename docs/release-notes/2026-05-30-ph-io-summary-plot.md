# PH-IO-5/7 — std.summary and std.plot

## Summary

Ship `std/summary` and `std/plot` modules so benchmarks ingest and static dashboard can build via `lic` without ad-hoc module-missing skips.

## Changed

| Area | Path |
|------|------|
| Modules | `std/summary/summary.li`, `std/plot/plot.li` |
| Runtime | `runtime/li_rt_ph_io.c` (bridge when `LI_BENCHMARKS_ROOT` set) |
| Seam | `std/runtime/seam.li` — `summary_build_i`, `plot_render_dashboard_i` |
| Resolver | `compiler/types/import_resolve.cpp` — `summary` / `plot` imports |
| Tests | `li-tests/stdlib_coverage/build_std_summary_plot.li` |

## Downstream

Set `LI_BENCHMARKS_ROOT` in `build-summary-li.sh` / `render-static.sh`. Pure-Li ingest/plot logic follows in a later slice; bridge calls `benchmarks/scripts/ingest/summary_build_from_paths.py` and `scripts/dashboard/plot_render_dashboard.py`.
