# Gap closure queue (read-only audit)

**Generated:** 2026-05-25 (vertical gate alignment)  
**Sources:** `python3 ../benchmarks/scripts/plan-completion-audit.py` (`LIC_ROOT=$PWD`), [provability-gaps.md](provability-gaps.md), `gh pr list --repo li-langverse/lic --state open`, [proof-corpus-roadmap.md](proof-corpus-roadmap.md)  
**Machine audit:** `../benchmarks/data/latest/plan-completion-audit.json`

This file lists **prioritized open gaps not already claimed by an open PR**. Update after each gap-closure merge; do not treat rows here as closed until [provability-gaps.md](provability-gaps.md) or the master plan tracker moves in the **same PR** as the implementation.

**Gate evidence (v1):** `scripts/check-master-plan-gates.sh` → `scripts/check-master-plan-vertical-gates.sh` for shipped **PH-HW / Studio / MCP** stubs (#270 vertical merge partial slices). Decorator MIR checks run via `contracts_discharge_corpus.sh` only (no duplicate `check-mir-parallel-decorator` in the top-level gate list).

---

## Vertical legend

| Vertical | Scope |
|----------|--------|
| **Compiler / Proof** | Phases **2e**, **2f**; **G-lean**, **G-vc**, **G-bnd**, **G-trust**, **G-narrow**, **G-oop** |
| **Math / HPC** | Phases **2i**, **7e**; **G-math**, **G-math-syn**; tier-1 benches |
| **Parallel / Decorators** | Phases **7b**, **7d**; **G-par**, **G-dec** |
| **Studio / UX** | **PH-UX**, **PH-GD**; `li-ui`, `li-gui`, adaptive layout, viewport |
| **Studio / HW** | **PH-HW**, **`lig` / `render`**; native present, wgpu readback |
| **Simulation** | **PH-SIM**; `li-sim-*`, tier-2, algo registry |
| **Agent / MCP** | **PH-AGENT**; `lis` MCP, tool dispatch |
| **Physics / Science** | **G-physics**, **P-physics**; tier-2 physics, proof-db physics entries |
| **Packages** | [algorithms-and-libraries-plan §7](../ecosystem/algorithms-and-libraries-plan.md) — `linalg`, `gui`, `anim`, … |
| **CI / Tooling** | **8p**, **Vision-LLM**; catalog paths, parallel compile SLO |
| **Data** | **PH-DB**; `lidb`, registry v2 |

**Product vertical IDs** (World Studio / demo capture — informal numbering in release notes):

| ID | Topic | Typical PH | Gate hook (partial) |
|----|--------|------------|---------------------|
| **#1** | Studio-ui bench / `lig` registry paths | PH-UX | `bench-lig-kernel-parity.sh`, `lig-kernels.toml` |
| **#2** | Native present + wgpu framebuffer readback | PH-HW | `studio-shell-present-tick.sh` (mock ok; GPU readback open) |
| **#3** | Sim domain profile packs | PH-SIM | domain stub packages; full SIM-1 stepping open |
| **#4** | Scientific sim step (MD stub) | PH-SIM | `import_studio_sim_step_by_profile.li` |
| **#6** | MCP `am_export_print` | PH-AGENT | `studio_mcp_extended.li` (`lic check`) |
| **#7** | MCP `chem_dft_run` / QM stub | PH-AGENT / PH-QM | `studio_mcp_extended.li`, `import_lig_chem_backend.li` |
| **#9** | Game sim step (`physics.runtime`) | PH-SIM / PH-GD | composable sim-step smokes |

---

## Open org issues ↔ master plan (2026-05-25)

Maps **`master-plan-gap`** / **`plan-needed`** issues to queue priority. Closing an issue requires tracker + provability register + gate evidence in the **same PR**.

| Issue | Title (short) | Queue rank | Vertical |
|------:|---------------|------------|----------|
| [#17](https://github.com/li-langverse/lic/issues/17) | G-lean / sqrt_open_bound / default Lean gate | 1 | Compiler / Proof |
| [#21](https://github.com/li-langverse/lic/issues/21) | Phase 2e / G-vc contracts | 2 | Compiler / Proof |
| [#32](https://github.com/li-langverse/lic/issues/32) | 2e–2f / 7e Lean+VC+G-math | 1–3 | Compiler + Math |
| [#20](https://github.com/li-langverse/lic/issues/20) | Phase 2i / `@` shape rules | 3 | Math / HPC |
| [#22](https://github.com/li-langverse/lic/issues/22) | Phase 7d / G-dec MIR lowering | 6 | Parallel / Decorators |
| [#27](https://github.com/li-langverse/lic/issues/27) | PH-7e / G-math Done criteria | 7 | Math / HPC |
| [#25](https://github.com/li-langverse/lic/issues/25) | Partial tracker closure evidence | meta | CI / Tooling |
| [#29](https://github.com/li-langverse/lic/issues/29) | Doc-c vs phase tracker | — | Docs (link [#26](https://github.com/li-langverse/lic/issues/26) / [#31](https://github.com/li-langverse/lic/issues/31)) |
| [#19](https://github.com/li-langverse/lic/issues/19) | Vision-LLM manifest CI | 13 | CI / Tooling |
| [#18](https://github.com/li-langverse/lic/issues/18) | Phase H M1 li-httpd `.li` | — | H (blocked on 2e–2f) |
| [#49](https://github.com/li-langverse/lic/issues/49) | provability-gaps table vs G-math | docs | Math / HPC |

**Not queued here:** explorer-finding issues ([#34](https://github.com/li-langverse/lic/issues/34)+) — triage via `plan-feature-from-issue`; benchmarks catalog path issues — see rank 16 below.

---

## Open PR map (2026-05-25)

Gaps **with an open PR** are **excluded** from the prioritized queue below (may still be partial until merge).

| PR | Branch | Vertical / gap | Notes |
|----|--------|----------------|-------|
| [#270](https://github.com/li-langverse/lic/pull/270) | `feat/vertical-gap-merge` | **Merged** — Studio/HW/SIM/MCP stubs | Gate alignment in this branch |
| [#290](https://github.com/li-langverse/lic/pull/290) | `fix/main-ci-vertical-merge` | CI repair post-#270 | Manifest + `resource_options_invalid` |
| [#288](https://github.com/li-langverse/lic/pull/288) | `feat/vertical-gap-wgpu-readback` | Studio **#2** readback | Phase A `present_blit_rgba8` |
| [#283](https://github.com/li-langverse/lic/pull/283) | `feat/studio-mcp-lis-server` | Agent **#6**, **#7** | `lis` stdio server beyond stub |
| [#291](https://github.com/li-langverse/lic/pull/291) | `feat/lig-lkir-wp2-matmul-md` | PH-HW WP2 | LKIR matmul oracle |
| [#294](https://github.com/li-langverse/lic/pull/294) | `feat/gap2-proof` | Compiler **G-lean** / **P-float** | Pairs with queue ranks 1–2 |
| [#286](https://github.com/li-langverse/lic/pull/286) | `feat/gap2-gitems` | **G-par** disjoint MIR | Pairs with rank 4 |
| [#183](https://github.com/li-langverse/lic/pull/183) | `cursor/compiler-only-vc-witness` | Compiler / Proof | VC witness; **G-lean** still open |

---

## Plan-completion audit snapshot

| Signal | Count |
|--------|------:|
| Master plan open phases | 5 (2i, 7d, 7e, 8p, Vision-LLM) |
| Plan-file open gates | 8+ |
| **G-*** partial | 14 |
| **G-*** missing | 4 (G-ann, G-gpu, G-meta, G-authz) |
| Catalog path gaps | 2 |

---

## Prioritized queue (not covered by open PRs)

| Rank | Pri | ID / phase | Vertical | What remains | Evidence |
|-----:|:---:|------------|----------|--------------|----------|
| 1 | **P0** | **G-lean** | Compiler / Proof | `--strict-lean` default; universal float/`abs` discharge | `check-autovc-open-goals.sh`, `glean_strict_build_smoke.sh` |
| 2 | **P0** | **G-vc** / **P-float** | Compiler / Proof | Close `sqrt_open_bound` + general float `ensures` | `discharge_sqrt_open_lean.sh` |
| 3 | **P0** | **Phase 2i** | Math / HPC | Float `vec3_dot` Props; no silent NumPy broadcast | `li-tests/math_linalg/` |
| 4 | **P0** | **G-par** | Parallel / Decorators | Lean lemmas for `disjoint=` | phase **7d** |
| 5 | **P0** | **G-bnd** | Compiler / Proof | Release builds without `li_bounds_fail` | `bounds_refinement_release_ok.li` |
| 6 | **P1** | **G-dec** | Parallel / Decorators | MIR proc tags → LLVM/OpenMP | `check-mir-*-decorator.sh` via corpus |
| 7 | **P1** | **Phase 7e** | Math / HPC | Tier-1 **≤1.2×** C++ | `check-tier1-li-vs-cpp.sh` |
| 8 | **P1** | Studio **#2** | Studio / HW | GPU **RenderReadPixels** / honest MP4 | beyond `studio-shell-present-tick` mock |
| 9 | **P1** | **G-physics** | Physics / Science | Tier-2 modeling_gap → contracts | `proof-database/entries/physics-*.toml` |
| 10 | **P1** | Studio **#3** | Simulation | Domain packs → real stepping | `li-sim-*` stubs |
| 11 | **P1** | **G-oop** | Compiler / Proof | Trait laws / `old(self.field)` | OOP roadmap **2j** |
| 12 | **P1** | **Phase 8p** | CI / Tooling | MIR/LLVM parallel; wall-time SLO | [parallel-compile-ci](../superpowers/plans/2026-05-22-parallel-compile-ci.md) |
| 13 | **P2** | **Vision-LLM** | CI / Tooling | `lic edit --patch=json`, manifest CI | [#19](https://github.com/li-langverse/lic/issues/19) |
| 14 | **P2** | Catalog | CI / Tooling | `tier0_stability` paths under `LIC_ROOT` | plan-completion-audit |

**Done (do not re-open):** **G-test-verify**. **Social only:** **G-hw**, **G-wrong-spec**.

---

## Agent maintenance

1. Re-run `plan-completion-audit.py` with `LIC_ROOT` set to this checkout.
2. Refresh [Open PR map](#open-pr-map-2026-05-25) from `gh pr list --repo li-langverse/lic --state open`.
3. Refresh [Open org issues](#open-org-issues--master-plan-2026-05-25) when labels/titles change.
4. Remove a queue row when the gap closes in **provability-gaps.md** / master plan **in the implementation PR**.
