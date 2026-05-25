# Gap closure queue (read-only audit)

**Generated:** 2026-05-25 (Phase 2a)  
**Sources:** `python3 ../benchmarks/scripts/plan-completion-audit.py` (`LIC_ROOT=$PWD`), [provability-gaps.md](provability-gaps.md), `gh pr list --repo li-langverse/lic --state open`, [proof-corpus-roadmap.md](proof-corpus-roadmap.md)  
**Machine audit:** `../benchmarks/data/latest/plan-completion-audit.json` (34 findings)

This file lists **prioritized open gaps not already claimed by an open PR**. Update after each gap-closure merge; do not treat rows here as closed until [provability-gaps.md](provability-gaps.md) or the master plan tracker moves in the **same PR** as the implementation.

---

## Vertical legend

| Vertical | Scope |
|----------|--------|
| **Compiler / Proof** | Phases **2e**, **2f**; **G-lean**, **G-vc**, **G-bnd**, **G-trust**, **G-narrow**, **G-oop** |
| **Math / HPC** | Phases **2i**, **7e**; **G-math**, **G-math-syn**; tier-1 benches |
| **Parallel / Decorators** | Phases **7b**, **7d**; **G-par**, **G-dec** |
| **Studio / UX** | **PH-UX**, **PH-GD**; `li-ui`, `li-gui`, adaptive layout, viewport |
| **Studio / HW** | **PH-HW**, **lig** / **render**; native present, wgpu readback |
| **Simulation** | **PH-SIM**; `li-sim-*`, tier-2, algo registry |
| **Agent / MCP** | **PH-AGENT**; `lis` MCP, tool dispatch |
| **Physics / Science** | **G-physics**, **P-physics**; tier-2 physics, proof-db physics entries |
| **Packages** | [algorithms-and-libraries-plan §7](../ecosystem/algorithms-and-libraries-plan.md) — `linalg`, `gui`, `anim`, … |
| **CI / Tooling** | **8p**, **Vision-LLM**; catalog paths, parallel compile SLO |
| **Data** | **PH-DB**; `lidb`, registry v2 |

**Product vertical IDs** (World Studio / demo capture — informal numbering in release notes):

| ID | Topic | Typical PH |
|----|--------|------------|
| **#1** | Studio-ui bench / `lig` registry paths | PH-UX |
| **#2** | Native present + wgpu framebuffer readback | PH-HW |
| **#3** | Sim domain profile packs | PH-SIM |
| **#4** | Scientific sim step (MD stub) | PH-SIM |
| **#6** | MCP `am_export_print` | PH-AGENT |
| **#7** | MCP `chem_dft_run` / QM stub | PH-AGENT / PH-QM |
| **#9** | Game sim step (`physics.runtime`) | PH-SIM / PH-GD |

---

## Open PR map (2026-05-25)

Gaps **with an open PR** are **excluded** from the prioritized queue below (may still be partial until merge).

| PR | Branch | Vertical / gap | Notes |
|----|--------|----------------|-------|
| [#253](https://github.com/li-langverse/lic/pull/253) | `feat/vertical-gap-sim-step-physics` | Simulation **#4**, **#9** | Step hooks + smokes; not full replay |
| [#252](https://github.com/li-langverse/lic/pull/252) | `feat/vertical-gap-mcp-chem` | Agent **#6**, **#7** | Contracts + DFT stub; no `lis` HTTP |
| [#251](https://github.com/li-langverse/lic/pull/251) | `feat/vertical-gap-bench-lig` | Studio **#1** (bench path) | Does not close **#2** readback |
| [#248](https://github.com/li-langverse/lic/pull/248) | `feat/ph-db-0-lidb-proposal` | Data | Doc cross-links only |
| [#245](https://github.com/li-langverse/lic/pull/245) | `feat/lic-execution-resources` | Parallel / Decorators | WP4 `--cores` / `--threads-per-core`; merge after **#208** |
| [#195](https://github.com/li-langverse/lic/pull/195) | `feat/studio-docs-def-not-proc` | Docs | No compiler change |
| [#194](https://github.com/li-langverse/lic/pull/194) | `cursor/compiler-studio-plan-loop` | Studio / UX | AL-9 `import gui` scaffold |
| [#188](https://github.com/li-langverse/lic/pull/188) | `cursor/sim-algo-plan-loop` | Simulation / Math | `num_dot_axpy` algo_id=1 only |
| [#183](https://github.com/li-langverse/lic/pull/183) | `cursor/compiler-only-vc-witness` | Compiler / Proof | VC witness slice; **G-lean** still open |

**Branches not in open PR list** (queue may still apply): `feat/vertical-gap-native-present` (**#2** partial), `feat/vertical-gap-sim-packs` (**#3**), `feat/vertical-gap-lig-kernels`, etc.

---

## Plan-completion audit snapshot

| Signal | Count |
|--------|------:|
| Master plan open phases | 5 (2i, 7d, 7e, 8p, Vision-LLM) |
| Plan-file open gates | 8 |
| **G-*** partial | 14 |
| **G-*** missing | 4 (G-ann, G-gpu, G-meta, G-authz) |
| Catalog path gaps | 2 |

---

## Prioritized queue (not covered by open PRs)

Ranked for agent dispatch. **P0** = blocks “`lic build` = proof certificate” or Wave A compiler-studio loop; **P1** = high leverage next slice; **P2** = important but deferrable.

| Rank | Pri | ID / phase | Vertical | What remains | Evidence |
|-----:|:---:|------------|----------|--------------|----------|
| 1 | **P0** | **G-lean** | Compiler / Proof | `--strict-lean`: fail `lic build` on any open AutoVC goal; universal float/`abs` discharge (not only `sqrt_open_bound` slice) | [provability-gaps.md](provability-gaps.md), `check-autovc-open-goals.sh`, `proof-database/DISCREPANCIES.md` |
| 2 | **P0** | **G-vc** / **P-float** | Compiler / Proof | Close `sqrt_open_bound` + general float `ensures`; loop vs closed-form witness parity | `sqrt_open_bound.li`, `discharge_sqrt_open_lean.sh`, **P-float** backlog |
| 3 | **P0** | **Phase 2i** / **P-linalg** | Math / HPC | Float `vec3_dot` Props, 2D `CallProc` matmul, explicit-only surface (no silent NumPy broadcast) | Master plan 2i row; `li-tests/math_linalg/` |
| 4 | **P0** | **G-par** / **P-par** | Parallel / Decorators | Lean lemmas for `disjoint=` (beyond AST `policy_module`) | `disc-g-par-lean-disjoint-missing`, phase **7d-c** |
| 5 | **P0** | **G-bnd** / **P-bnd** | Compiler / Proof | Release builds: proved indices must not rely on `li_bounds_fail` | [bounds-release-path.md](bounds-release-path.md), `bounds_refinement_release_ok.li` |
| 6 | **P1** | **G-dec** / **P-dec** | Parallel / Decorators | Full decorator elaboration: MIR proc tags → LLVM/OpenMP (not declare-only) | Phase **7d** tracker; `decorator_exploits/` |
| 7 | **P1** | **Phase 7e** | Math / HPC | Tier-1 **≤1.2×** C++ on refreshed hardware; **pure-Li `simd_dot`** at realistic wall time | `compiler-studio-plan-loop` wave-a-7e-*; `check-tier1-li-vs-cpp.sh` |
| 8 | **P1** | Studio **#2** | Studio / HW | wgpu-rs / swapchain **RenderReadPixels**; honest MP4 from GPU (not CPU stub only) | [VERTICALS-RECORDING.md](../demo/VERTICALS-RECORDING.md) |
| 9 | **P1** | **G-physics** / **P-physics** | Physics / Science | Tier-2 `extern` **modeling_gap** → proved contracts; close open **P-LM-*** | `proof-database/entries/physics-*.toml`, `benchmarks/tier2_physics/` |
| 10 | **P1** | Studio **#3** | Simulation | Merge domain packs + wire profiles to real `li-sim-*` stepping (stubs → SIM-1) | `feat/vertical-gap-sim-packs` (no open PR at audit time) |
| 11 | **P1** | **G-oop** | Compiler / Proof | Trait laws, `old(self.field)`, cross-module method privacy proofs | `encapsulation/trait_*.li`, OOP roadmap **2j** |
| 12 | **P1** | **Phase 8p** | CI / Tooling | MIR/LLVM parallel passes; wall-time SLO vs `-j1` (beyond **8p-a–d**) | [2026-05-22-parallel-compile-ci.md](../superpowers/plans/2026-05-22-parallel-compile-ci.md) |
| 13 | **P2** | **Vision-LLM** | CI / Tooling | `lic edit --patch=json`, symbol compression, advisory `--deny-warnings` JSON | Master plan Vision-LLM row |
| 14 | **P2** | **AL-10** `linalg` package | Packages | New `packages/linalg` + `math_linalg` tests (monorepo gap register) | [algorithms-and-libraries-plan §7](../ecosystem/algorithms-and-libraries-plan.md) |
| 15 | **P2** | **G-gpu** | Compiler / Proof | `@gpu` address-space proofs + codegen | Phase 3+; spec only today |
| 16 | **P2** | Catalog | CI / Tooling | `tier0_stability`, `rate_limit_429` paths missing under `LIC_ROOT` | `benchmarks/data/latest/plan-completion-audit.json` |
| 17 | **P2** | **G-ann** | Compiler / Proof | PEP 649 deferred annotations | Phase 4 plan |
| 18 | **P2** | **G-meta** / **G-authz** | Compiler / Proof / OS | Research compiler≡Lean; capability IDOR (OS phase) | provability-gaps register |

**Social / axiomatic (not queued for implementation):** **G-hw**, **G-wrong-spec**. **Done (do not re-open):** **G-test-verify**.

---

## Suggested dispatch order (next 3 PRs)

1. **P0 compiler:** stack **G-lean** + **G-vc** / **P-float** on one branch (after **#183** merges or rebases).
2. **P0 parallel proof:** **G-par** Lean slice (pairs with **#245** execution resources, not a substitute).
3. **P1 product:** Studio **#2** readback **or** Simulation **#3** domain wiring — pick one vertical per PR; keep proof/compiler Wave A unblocked.

---

## Agent maintenance

1. Re-run `plan-completion-audit.py` after `git fetch origin`.
2. Refresh the [Open PR map](#open-pr-map-2026-05-25) from `gh pr list --repo li-langverse/lic --state open`.
3. Remove a queue row when the gap closes in **provability-gaps.md** / master plan **in the implementation PR**.
4. Do not duplicate work already on an open PR branch listed above.
