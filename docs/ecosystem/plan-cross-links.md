# Plan cross-links (master plan ↔ gaps ↔ phases)

Agents use this map so **vision**, **PH trackers**, and **honest proof status** stay aligned across repos.

## Canonical documents

| Layer | Path |
|-------|------|
| **Master plan** (PH order, repo policy) | [`docs/superpowers/plans/2026-05-14-li-master-plan.md`](../superpowers/plans/2026-05-14-li-master-plan.md) |
| **Provability gaps (G-*)** | [`docs/verification/provability-gaps.md`](../verification/provability-gaps.md) |
| **Phase plans** | [`docs/superpowers/plans/`](../superpowers/plans/) (`2026-05-14-phase-*.md`, product plans) |
| **Proof corpus backlog** | [`docs/verification/proof-corpus-roadmap.md`](../verification/proof-corpus-roadmap.md) |
| **Org vision & governance** | [roadmap — vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| **Benchmark catalog & dashboard** | [benchmarks — catalog](https://github.com/li-langverse/benchmarks/blob/main/catalog.toml) · [dashboard](https://li-langverse.github.io/benchmarks/) |
| **Benchmarks cross-link mirror** | [plan-cross-links (benchmarks)](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/plan-cross-links.md) |

## Edit rules

1. **Cross-repo or pillar change** → update **master plan** + open **roadmap** proposal (human merge on governance paths).
2. **Close a G-* row** → same PR as the implementation; update **provability-gaps.md** (Partial → Done only with evidence cited in the table).
3. **Close a PH phase checkbox** → same PR as the deliverable; link bench rows or `li-tests` where applicable.
4. **Perf claim** → `catalog.toml` row + ingest; cite dashboard URL; do not mark proof **Done** from bench green alone.

## Open master-plan tracker rows (2026-05-30)

Honest **partial** rows only — do not check `[x]` without cited tests, Lean, or scripts.

| PH | Gap ID(s) | Phase plan / spec |
|----|-----------|-------------------|
| **2i** — Math / linalg | **G-math**, **G-math-syn** | [`2026-05-16-li-math-linalg-surface.md`](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) · [`2026-05-14-phase-07-native-hpc.md`](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) |
| **7d** — Execution decorators | **G-dec**, **G-par** | [`2026-05-16-li-execution-decorators.md`](../superpowers/specs/2026-05-16-li-execution-decorators.md) · [`2026-05-14-phase-07-native-hpc.md`](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) |
| **7e** — Math → SIMD lowering | **G-math** | [`2026-05-16-li-math-linalg-surface.md`](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) · [`2026-05-14-benchmarks-and-simulations.md`](../superpowers/plans/2026-05-14-benchmarks-and-simulations.md) |
| **8p** — Parallel compile / CI | — | [`2026-05-22-parallel-compile-ci.md`](../superpowers/plans/2026-05-22-parallel-compile-ci.md) · [master plan § 8p](../superpowers/plans/2026-05-14-li-master-plan.md#phase-8p--parallel-compile--ci-throughput) |
| **Vision-LLM** — Agent JSON diagnostics | — | [`2026-05-16-li-llm-first-design.md`](../superpowers/specs/2026-05-16-li-llm-first-design.md) · [`agent-handover-formats.md`](agent-handover-formats.md) |
| **PH-UX** — Studio UI/UX (not Lean) | — | [`2026-05-24-studio-ui-ux-plan-loop.md`](../superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md) · [gui_ux_tester digests](https://github.com/li-langverse/benchmarks/tree/main/docs/ecosystem/ux-digests) |

## Phase plan index

| Plan | PH / topic |
|------|------------|
| `2026-05-14-phase-00-bootstrap.md` | Bootstrap |
| `2026-05-14-phase-01-lexer-parser.md` | Parser |
| `2026-05-14-phase-02-typechecker.md` | Types · **G-vc**, **G-bnd**, **G-math-syn** |
| `2026-05-14-phase-03-mir-codegen.md` | MIR / LLVM · **G-bnd**, **G-meta** |
| `2026-05-14-phase-04-runtime-stdlib.md` | Runtime / std · **G-ann** |
| `2026-05-14-phase-05-tetris.md` | Demo game |
| `2026-05-14-phase-06-self-host.md` | Self-host |
| `2026-05-14-phase-07-native-hpc.md` | **PH-5b**, SIMD / tier-1 · **G-par**, **G-dec**, **G-math** |
| `2026-05-14-benchmarks-and-simulations.md` | Bench harness |
| `2026-05-16-li-package-manager-lip.md` | **lip** |
| `2026-05-16-li-httpd-plan.md` | **lis** / httpd |
| `2026-05-16-li-math-linalg-surface.md` | **PH-2i**, **PH-7e** · **G-math** |
| `2026-05-22-parallel-compile-ci.md` | **PH-8p** |
| `2026-05-24-studio-ui-ux-plan-loop.md` | **PH-UX** / Studio (UX honesty, not Lean) |

## UI / UX audit handoff (research goal `ui_ux_quality`)

Surface quality is **not** proof — keep separate from **G-*** rows.

| Agent | Surface | Digest path (benchmarks) |
|-------|---------|--------------------------|
| `gui_ux_tester` | GUI apps, fixtures, native SDL | [`docs/ecosystem/ux-digests/`](https://github.com/li-langverse/benchmarks/tree/main/docs/ecosystem/ux-digests) |
| `docs_ui_tester` | MkDocs / handbook Pages | same tree (`2026-05-30-docs-ui.md`) |
| `studio_ui_ux_builder` | PH-UX plan loop, bench gates | [`data/latest/studio-ui-ux-builder-digest.md`](https://github.com/li-langverse/benchmarks/blob/main/data/latest/studio-ui-ux-builder-digest.md) |

Remediation manifest: `benchmarks/data/latest/remediation_manifest.json` (issue URLs + acceptance checklists).

## Automation

From **benchmarks** checkout: `python3 scripts/plan-completion-audit.py` (reads **LIC_ROOT**). Output: `data/latest/plan-completion-audit.json`.
