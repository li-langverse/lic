# Benchmark dual-mode guide

<!-- DOC-PAR-09 -->

Org benchmark suite emits paired `li_serial` and `li_parallel` rows for dashboard speedup columns.

## Quick run

```bash
packages/li-parallel/scripts/lipar-suite.sh --profile pr --dual-mode --cores 8
```

| Flag | Effect |
|------|--------|
| `--profile pr` | Class A tier1+2 slice (PR gate) |
| `--profile full` | Whole catalog tiers 0–7 (killer gate) |
| `--dual-mode` | Emit both `li_serial` and `li_parallel` langs |
| `--cores N` | Thread count for parallel pass |
| `--scope` | `class_a` (PR) or `all` (killer / full profile) — see `lipar-dual-mode-csv.py` |
| `--skip-serial` | Parallel pass only |
| `--skip-parallel` | Serial pass only |

## CSV columns

| Column | Meaning |
|--------|---------|
| `benchmark` | Harness id (e.g. `matmul_blocked`) |
| `lang` | `li_serial` or `li_parallel` |
| `metric` | `wall_time` |
| `value` | Seconds |

Dashboard computes `speedup_vs_serial = li_serial / li_parallel`.

## Gates

| Gate | Command | Scope |
|------|---------|-------|
| PR progress | `scripts/check-li-parallel-full-suite.sh` | Class A tier1+2 |
| Killer completion | `scripts/check-li-parallel-killer-gate.sh` | Full tiers 0–7 |

## Perf advisory (WP-PAR-40)

```bash
LI_LIPAR_PERF_STRICT=1 ./scripts/check-li-parallel-perf-gate.sh
```

Thresholds: min 1.05× serial speedup (when serial ≥ 5 ms), max 1.2× vs C++.

See [release notes](../../../docs/release-notes/2026-06-06-li-parallel-perf-gate.md).
