# li-parallel killer loop — iteration log

## 2026-06-06 — Gate hardening (human session)

- Removed `LIPAR_KILLER_SKIP_FULL` escape hatch from killer gate
- Added sub-gates: docs, compile-smoke, catalog audit, distributed, FL, comm, hetero, xfer, proofs, chip boundaries
- Created canonical goal `li-parallel-killer-package.md` with honest Phases 5–99 **PENDING**
- Fixed benchmarks PR #370 CI: restored `data/latest/summary.json` from main (bad ph-ml ingest had 1 green row)
- Scaled K8s `li-li-parallel` to 0; ConfigMap goal → killer package

**Blocker:** killer gate fails at `check-li-parallel-docs-gate.sh` (expected until WP-PAR-50+ land).

## 2026-06-06 — Phase 5 docs corpus (code_implementer)

- Added DOC-PAR-01–14: handbook, API ref (shared/distributed/kernels), OpenMP/MPI migration, examples, dual-mode guide, proofs table, gap register, mkdocs nav manifest
- `check-li-parallel-docs-gate.sh` now verifies corpus markers (WP-PAR-50–55 **DONE**)
- Killer blocker advances to `check-li-parallel-compile-smoke-gate.sh` (WP-PAR-07–09)

## 2026-06-06 — WP-PAR-07–09 compile slice (code_implementer)

- Parser: `team(cores=N)`, `cluster(world=N, hosts="…")`, `overlap comm`, `@offload`
- Embedded `__li_exec_plan` global + `runtime/li_exec_plan.c` apply at main
- Compile smoke gate green (6 specimens + 6 smokes)
- Killer blocker advances to catalog audit / distributed sub-gates

## 2026-06-06 — WP-PAR-70–75 comm plan slice (code_implementer)

- Embedded `__li_comm_plan` global + `runtime/li_comm_plan.c` apply at main
- Overlap comm MIR wired to comm plan runtime (`li_comm_overlap_region`)
- MD ghost overlap smoke ≥50% + cluster gather validation
- RDMA hook stub, latency bench, compressed halo bench
- `check-li-parallel-comm-gate.sh` green
- Killer blocker advances to `check-li-parallel-hetero-gate.sh` (li-gpu / li-tpu / li-asic packages)

## 2026-06-06 — WP-PAR-48 whole-catalog dual-mode CSV (code_implementer)

- `lipar-dual-mode-csv.py --scope all` tags every `lang=li` row as `li_serial`/`li_parallel`
- `lipar-suite.sh --profile full` passes `--scope all`; PR profile keeps Class A (`class_a`)
- Killer gate dual-mode check scoped to Li benchmarks only (excludes security-only rows)
- Test: `li-tests/tooling/li_parallel_dual_mode_csv.sh` catalog scope case

## 2026-06-07 — WP-PAR-02 tier CSV merge (code_implementer)

- `scripts/lipar-merge-tier-csv.py` merges tier-tier*.csv perf shards into `results/latest.csv` after full suite
- `lipar-suite.sh --profile full` and killer gate step 3 call merge before dual-mode CSV tagging
- Test: `li-tests/tooling/li_parallel_merge_tier_csv.sh`
- Killer blocker advances from empty `latest.csv` wall_time rows (tier-5 HTTP ingest overwrite) toward dual-mode breadth check

## 2026-06-06 — WP-PAR-02 full-suite prereqs (code_implementer)

- `scripts/lib/lipar-suite-prereqs.sh` builds li-httpd + exports `TIER5_EXPLOIT_LANGS=nginx,li`
- `lipar-suite.sh --profile full` and killer gate step 3 call prereqs before `run-full-benchmark-suite.sh`
- Test: `li-tests/tooling/li_parallel_full_suite_prereqs.sh`
- Killer blocker advances from tier5 exploit harness abort (missing li-httpd / apache noise) toward dual-mode CSV breadth check

## 2026-06-07 — WP-PAR-15 team-scoped reduce + killer gate PASS (code_implementer)

- Added `team_block_reduce_f64.li` + `li_team_block_reduce_codegen_smoke.sh` (team push/pop + parallel for reduce)
- Wired smoke into `check-li-parallel-compile-smoke-gate.sh`
- Updated gap register + goal phase tables: WP-PAR-15/17/19/40/48/07–09/99 **DONE**
- Killer gate **PASS**: 152 benchmarks, dual-mode complete, all sub-gates green (~11 min local)
- Progress gate **PASS** (advisory reduce_sum perf gap under non-strict mode)

## 2026-06-07 — G-par decorator-inherit proof slice (code_implementer)

- Added `def_disjoint_inherit_tile` lemma + proof-db entries `P-par-def-disjoint-inherit-*` under G-par
- `li_parallel_def_disjoint_inherit_smoke.sh` wired into compile-smoke + proofs gates
- Proofs gate now verifies G-par register rows alongside G-par-dist + G-hetero
- Progress gate **PASS**; killer gate unchanged green (152 benchmarks dual-mode)

## 2026-06-07 — G-par memory-disjoint rows proof slice (code_implementer)

- Added `memory_disjoint_rows_spec` + witness + bridge lemma in `Discharge.lean`
- Added `par_memory_disjoint_rows` lemma in `parallel/proof.li` + proof-db entry `P-par-memory-disjoint-rows`
- `li_par_memory_disjoint_rows_smoke.sh` wired into proofs gate
- Progress gate **PASS**; killer gate re-verify pending (lic build)

## 2026-06-07 — G-par team-reduce proof slice + gate re-verify (code_implementer)

- Added `team_cores_bounded` + `team_reduce_tile_disjoint` lemmas in `parallel/proof.li` (WP-PAR-15/16/19)
- Proof-db entries `P-par-team-reduce-smoke` + `P-par-team-reduce-tile-disjoint` under G-par
- Re-ran killer gate **PASS** (~11 min) and progress gate **PASS** (reduce_sum 159.5× advisory)

## 2026-06-07 — G-par memory-disjoint rows proof slice (code_implementer)

- Added `memory_disjoint_rows_spec` + witness + bridge lemma in `Discharge.lean`
- Added `par_memory_disjoint_rows` lemma in `parallel/proof.li` + proof-db entry `P-par-memory-disjoint-rows`
- `li_par_memory_disjoint_rows_smoke.sh` wired into proofs gate
- Progress gate **PASS**; killer gate re-verify pending (lic build)

## 2026-06-07 — G-par memory-disjoint elems proof slice (code_implementer)

- Added `memory_disjoint_elems_spec` + witness + bridge + `array_elem_indices_disjoint` in `Discharge.lean`
- Added `par_memory_disjoint_elems` lemma in `parallel/proof.li` + proof-db entry `P-par-memory-disjoint-elems`
- `li_par_memory_disjoint_elems_smoke.sh` wired into proofs gate
- Proofs gate **PASS**; progress gate **PASS**; killer gate unchanged green
