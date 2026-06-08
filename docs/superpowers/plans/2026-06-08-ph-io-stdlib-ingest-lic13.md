# PH-IO-4/5/7: ship std.io, std.csv, std.summary, std.plot runtime (lic#13)

> **Issue:** [#13](https://github.com/li-langverse/lic/issues/13) · **Repo:** li-langverse/lic  
> **Vision:** **Easy** (Li-first ingest), **Provable** (bounded IO + honest parity gates), **Fast** (deferred — correctness before perf)  
> **Learned from:** [ecosystem-first](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/ecosystem-first.md), [stdlib.md](../../language/stdlib.md), [PH-7e benchmark honesty](2026-05-30-ph7e-tier1-red-benchmark-honesty.md), [phase-04 runtime stdlib](2026-05-14-phase-04-runtime-stdlib.md)

**north_star_fit:** ecosystem / scientific_computing · **PH-IO-4**, **PH-IO-5**, **PH-IO-7**, **PH-5b** (dashboard ingest honesty)

## Goal

Upgrade the four **compile-only** PH-IO std modules (`std/io`, `std/csv`, `std/summary`, `std/plot`) from tag stubs to **working runtime** so **benchmarks** ingest and static dashboard scripts run on Li paths by default. Python (`build_summary.py`, `plot_render_dashboard.py`) remains the **parity gate**, not the primary path.

**Current state (2026-06-08):** modules exist on `main` with `io_tag`/`csv_tag`/`summary_tag`/`plot_tag` stubs and `li-tests/stdlib_seal` compile harnesses. Benchmarks `.li` scripts already import the **target API** (`io_read_file`, `csv_parse`, `summary_build`, `plot_render_dashboard`) but those symbols are not yet implemented.

## Non-goals

- Weakening `threshold_ratio_cpp` or catalog thresholds in **benchmarks** to green incomplete kernels.
- Copying **lic** `benchmarks/harness` into **benchmarks** (ingest-only per ecosystem-first).
- Full feature parity with all of `build_summary.py` (1400+ lines) in v1 — ship the **contract exercised by fixtures + compare gate**.
- Node/Vite `dashboard/` bundle on the critical path (static HTML+SVG only).
- Editing `trusted.lean` without a linked human-approved issue.
- `Any`, `unsafe`, or unproved IO shortcuts.

## Dependencies

| Upstream | Notes |
|----------|-------|
| **PH-IO-4** | `std.bytes` extern seam (`bytes_len`, `bytes_append`, …) — reuse for blob buffers |
| **PH-IO-7** | `catalog.toml` schema stable in **benchmarks**; `compare_summary_outputs.py` gate |
| **PH-IO-5** | `data/latest/summary.json` shape from PH-IO-7 |
| **benchmarks** PRs #3–#5 | Ingest/dashboard loop blocked until lic runtime lands |
| **Human** | `trusted.lean` entries for new `li_rt_io` / `li_rt_csv` externs |
| **Human** | Label **`plan-approved`** on #13 before implementation agents run |

## Target API (benchmarks contract)

Derived from `benchmarks/scripts/ingest/csv_ingest_smoke.li`, `build_summary.li`, `render_dashboard.li`:

### std.io (`std/io/io.li`)

| Symbol | Signature (v1) | Behavior |
|--------|----------------|----------|
| `io_read_file` | `(path: str, max_bytes: int) -> ptr` raises `IO, Alloc` | Read ≤ `max_bytes` from file; return opaque blob handle |
| `io_blob_data` | `(blob: ptr) -> ptr` | Pointer to bytes (NUL-safe length via `io_blob_len`) |
| `io_blob_len` | `(blob: ptr) -> int64` | Byte length |
| `io_free` | `(blob: ptr) -> unit` | Release blob |

### std.csv (`std/csv/csv.li`)

| Symbol | Signature (v1) | Behavior |
|--------|----------------|----------|
| `csv_parse` | `(data: ptr, n: int64) -> ptr` raises `Alloc` | Parse header + rows from memory buffer |
| `csv_row_count` | `(doc: ptr) -> int` | Row count (excl. header) |
| `csv_col_index` | `(doc: ptr, name: str) -> int` | Column index by header name (-1 if missing) |
| `csv_free` | `(doc: ptr) -> unit` | Release parse tree |

### std.summary (`std/summary/summary.li`)

| Symbol | Signature (v1) | Behavior |
|--------|----------------|----------|
| `summary_build` | `(catalog, lic_csv, lis_csv, stability_csv, out_json: str) -> int` raises `IO, Alloc` | Build `summary.json`; return 0 on success |

v1 may call `summary_build_from_paths.py` via documented env bridge **only in CI fallback**; primary path is native Li/C runtime. Parity gate: `compare_summary_outputs.py`.

### std.plot (`std/plot/plot.li`)

| Symbol | Signature (v1) | Behavior |
|--------|----------------|----------|
| `plot_render_dashboard` | `(summary_json, out_html: str) -> int` raises `IO, Alloc` | Emit `index.html` + `assets/style.css` (static SVG bar charts) |

Match output shape of `plot_render_dashboard.py` for fixture summary files.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **std.io runtime** — `runtime/li_rt_io.c`, extern procs in `io.li`, bounds on `max_bytes` | `csv_ingest_smoke.li` reads `fixtures/lic_sample.csv` and exits 0 |
| **B** | **std.csv runtime** — `runtime/li_rt_csv.c`, RFC4180-ish parser (quoted fields, header row) | `csv_ingest_smoke.li` asserts row_count=2, col indices for `benchmark`/`lang` |
| **C** | **std.summary runtime** — catalog+CSV merge → JSON writer; fixture subset first | `build-summary-li.sh` PASS; `compare_summary_outputs.py` fixture gate PASS |
| **D** | **std.plot runtime** — JSON load + HTML/SVG/CSS writer (no JS) | `render-static.sh` PASS on fixture `summary.json` |
| **E** | **Ingest default flip** — `ingest-lic.sh` uses Li scripts first; Python only on Li failure | **benchmarks** CI `ingest-lic` job green with `LIC_ROOT` set |
| **F** | **Docs + seal sync** — `stdlib.md` maturity Partial→Shipped; prelude seal list; release note | `check-stdlib-coverage.sh` + `stdlib_seal` 9/9 pass |

## Tests / benches

| Gate | Path | PH |
|------|------|-----|
| CSV smoke | `benchmarks/scripts/ingest/ingest-csv-smoke.sh` | PH-IO-4 |
| Summary build | `benchmarks/scripts/ingest/build-summary-li.sh` | PH-IO-7 |
| Summary parity | `benchmarks/scripts/ingest/compare_summary_outputs.py` | PH-IO-7 |
| Static dashboard | `benchmarks/scripts/dashboard/render-static.sh` | PH-IO-5 |
| Stdlib seal | `li-tests/stdlib_seal/import_std_io_csv_ok.li`, `import_std_summary_plot_ok.li` | PH-IO-4/5/7 |
| Stdlib coverage | `li-tests/stdlib_coverage/build_std_csv.li`, `build_std_summary_plot.li` | PH-IO-4/5/7 |
| Full ingest | `benchmarks/scripts/ingest/ingest-lic.sh` | PH-IO-4/5/7 |

**li-tests additions (implementation PR):**

- `li-tests/stdlib_io/csv_ingest_smoke.li` — copy of benchmarks smoke (runs in lic CI)
- `li-tests/stdlib_summary/summary_fixture_parity.li` — fixture catalog + compare hook
- `li-tests/stdlib_plot/render_fixture_dashboard.li` — HTML output byte-stable on fixture

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-io** (new row) | Partial | File read bounded by `max_bytes`; `requires 0 <= max_bytes`; `decreases max_bytes` on read loops |
| **G-lean** | Partial | Extern contracts on `li_rt_io_read_file`; no new axioms without human `trusted.lean` PR |
| **G-sec** | Partial | Path traversal rejected (`..`, absolute paths outside CWD policy); no shell invocation from Li APIs |
| **G-perf** | Honest defer | IO/plot not on tier-1 bench path; no perf claims in v1 |

**Human-only:** PR adding `li_rt_io_*` / `li_rt_csv_*` to `docs/semantics/trusted.lean` with explicit bounds story.

## Rollout

1. **This PR** — plan doc only (draft); maintainer adds **`plan-approved`** on #13.
2. **lic** implementation PR #1 — sub-phases A+B (`std.io` + `std.csv`); unblock `ingest-csv-smoke.sh`.
3. **lic** implementation PR #2 — sub-phase C (`std.summary`); enable `build-summary-li.sh` + compare gate.
4. **lic** implementation PR #3 — sub-phase D (`std.plot`); enable `render-static.sh`.
5. **benchmarks** PR — sub-phase E: flip `ingest-lic.sh` default; re-enable dashboard-static hard gate per [2026-05-17 release note](https://github.com/li-langverse/benchmarks/blob/main/docs/release-notes/2026-05-17-ci-vite-dashboard-gate.md).
6. **lic** doc PR — sub-phase F: `stdlib.md`, `ecosystem-package-backlog.md`, release note.
7. Close #13 when ingest-lic + render-static green on org CI with Python parity gates passing.

## Human-only

- [ ] Label **`plan-approved`** on [#13](https://github.com/li-langverse/lic/issues/13) before codegen agents run.
- [ ] Review + merge **`trusted.lean`** extern surface PR (IO/CSV C runtime).
- [ ] Remove **`plan-needed`** after plan PR merges.
- [ ] Do **not** self-merge this planning PR without review.
