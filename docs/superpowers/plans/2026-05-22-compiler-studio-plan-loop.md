---
name: Compiler + Studio plan loop
overview: Weekend autonomous loop — Wave D/E package+vertical+Studio backlog from algorithms-and-libraries-plan §7–8 until next Monday 08:00. Not httpd.
todos:
  - id: wave-a-7e-verify
    content: "Tier-1 result verify — reference.py + bench-verify-results.sh 1; all checksums pass"
    status: completed
  - id: wave-a-7e-pure-li-simd
    content: "Pure-Li simd_dot — correct spec checksum at realistic wall time (DCE allowed if verified)"
    status: completed
  - id: wave-a-7e-matmul-pure
    content: "Pure-Li matmul_naive/matmul_blocked — maintain verify + perf row honesty"
    status: completed
  - id: wave-a-7e-horner
    content: "horner_pure_li — volatile sink + reference; no unverified fast-math DCE"
    status: completed
  - id: wave-a-2f-lean-strict
    content: "G-lean — autovc_lake_typecheck + glean_strict_build_smoke green on lic build"
    status: completed
  - id: wave-a-2f-vc-corpus
    content: "contracts_discharge_corpus + contracts_verify_lean; close sqrt_open_bound or document"
    status: completed
  - id: wave-a-2i-explicit-math
    content: "2i — explicit math only (dot, matmul, sum, element-wise on matching shapes); reject NumPy broadcast; document tensor/quaternion path"
    status: completed
  - id: wave-a-7d-vectorized
    content: "7d — @vectorized on def + Lean G-par disjoint roadmap note"
    status: completed
  - id: wave-b-tier2-verify
    content: "Tier-2 physics — verify.py green on md_lennard_jones + one PDE smoke"
    status: completed
  - id: wave-b-md-oracle
    content: "md_lennard_jones — external oracle column plan in competitive-engines (doc + stub driver)"
    status: completed
  - id: studio-math-goldens
    content: "verify-math-physics-goldens.sh in CI gates; li-math golden procs documented"
    status: completed
  - id: studio-algo-wave-a-doc
    content: "algorithms-and-libraries-plan Wave A table synced to provability-gaps"
    status: completed
  - id: studio-ph-ux-slice
    content: "PH-UX — one adaptive layout composable + li-tests compile_ok (no httpd)"
    status: completed
  - id: wave-c-competitive-intel
    content: "Download Layer C UX intel — competitive-intel/ + fetch script + ui-ux-by-dimension.md"
    status: completed
  - id: wave-c-verticals-toml
    content: "AL-1 benchmarks/competitive/verticals.toml + vertical-algorithm-catalog stub"
    status: completed
  - id: wave-c-ui-rect-vc
    content: "li-ui rect_contains single-return VC + composable compile_ok"
    status: completed
  - id: wave-d-gui-scaffold
    content: "AL-9 packages/gui scaffold + composable import gui (studio shell; UX-02/04)"
    status: in_progress
  - id: wave-d-02-al2-catalog
    content: "AL-2 vertical-algorithm-catalog.md — one kernel section per verticals.toml row"
    status: pending
  - id: wave-d-03-ux-inspector
    content: "PH-UX inspector/properties panel stub in li-ui (UX-04, scientific-editor intel)"
    status: completed
  - id: wave-d-04-math-quat-mat4
    content: "AL-11 math quat_dot/slerp/mat4_mul + scene.Transform3 wire-up + li-tests"
    status: completed
  - id: wave-d-05-linalg-scaffold
    content: "AL-10 packages/linalg scaffold + composable matmul smoke + math_linalg test"
    status: completed
  - id: wave-d-06-gpu-wgpu-smoke
    content: "gpu package — device enum + wgpu smoke composable (LKIR stub ok)"
    status: completed
  - id: wave-d-07-render-present
    content: "render — present/swapchain stub + import render composable"
    status: completed
  - id: wave-d-08-scene-hierarchy
    content: "scene — hierarchy + transform via math.Quat + composable"
    status: completed
  - id: wave-d-09-assets-gltf
    content: "assets — glTF ingest stub + composable import"
    status: completed
  - id: wave-d-10-ui-studio-wire
    content: "ui extend — studio chrome hooks + wire gui import in packages/studio"
    status: completed
  - id: wave-d-11-ux-dock-ux02
    content: "PH-UX dock/workspace chrome from competitive-intel UX-02 + adaptive_layout"
    status: completed
  - id: wave-d-12-ux-command-palette
    content: "PH-UX command palette / agent cmd IDs stub (UX-01 patterns)"
    status: completed
  - id: wave-d-13-anim-scaffold
    content: "AL-12 packages/anim — keyframe/clip types + composable"
    status: completed
  - id: wave-d-14-seq-scaffold
    content: "AL-12 packages/seq — shot/timeline types + composable"
    status: completed
  - id: wave-d-15-geometry-scaffold
    content: "AL-13 packages/geometry — mesh predicates stub + composable"
    status: completed
  - id: wave-d-16-cad-fundamentals
    content: "AL-4 docs/ecosystem/cad-fundamentals.md merge + link geometry PH"
    status: completed
  - id: wave-d-17-cae-rfc
    content: "AL-5 engineering/CAE RFC stub (FEA/CFD split from PH-SCI)"
    status: completed
  - id: wave-d-18-cinematic-rfc
    content: "AL-6 cinematic algorithm RFC (encode/color/audio; not UX-only)"
    status: completed
  - id: wave-d-19-vertical-gaming
    content: "gaming — physics.rigid composable + verticals.toml notes + bench row"
    status: pending
  - id: wave-d-20-vertical-md-oracle
    content: "MD — md_oracle driver stub doc + verticals.toml LAMMPS column plan"
    status: pending
  - id: wave-d-21-vertical-chem
    content: "chem — DFT composable smoke + qm_dft vertical row honesty"
    status: pending
  - id: wave-d-22-vertical-bioeng
    content: "bioeng — LITL workflow composable + bioengineering.toml hook"
    status: pending
  - id: wave-d-23-vertical-robo
    content: "sim.robotics — workspace composable + PH-ROBO cross-link"
    status: pending
  - id: wave-d-24-vertical-am
    content: "sim.additive — slicer workflow composable + am_slicer vertical"
    status: pending
  - id: wave-d-25-vertical-viz
    content: "sim.viz — pipeline source/display stub (ParaView UX-03 patterns)"
    status: pending
  - id: wave-d-26-vertical-mmo
    content: "mmo — shard composable + mmorpg.toml bench stub row"
    status: pending
  - id: wave-d-27-physics-deepen
    content: "physics.* — one tier-2 kernel harden (rigid or soft) + verify.py note"
    status: pending
  - id: wave-d-28-studio-compose
    content: "studio — compose ui+gui+render+world public API + composable"
    status: pending
  - id: wave-e-01-rect-vc-close
    content: "li-ui rect_contains VC close → composable compile_ok (was wave-c)"
    status: pending
  - id: wave-e-02-player-hud
    content: "player — load gui HUD composable + import test"
    status: pending
isProject: false
---

# Compiler + Studio autonomous loop

**Not in scope:** `li-httpd`, tier5 HTTP — use `httpd-plan-loop.py` in a separate process.

**Priority:** [algorithms-and-libraries-plan](../../ecosystem/algorithms-and-libraries-plan.md) Wave **D→E** (packages, verticals, Studio) — Wave A–C rows in plan YAML are **completed**; keep gates green.

**Continuous driver:** `./scripts/compiler-studio-plan-continuous.sh` — runs agent batches while plan todos are `pending`/`in_progress`; **sleeps 30 min** when idle (nothing to implement). Add new todos to the plan YAML to resume work.

**Autostart + reboot:** `./scripts/install-plan-loop-systemd.sh` — user systemd + linger. Stop: `./scripts/install-plan-loop-systemd.sh --disable` or `touch data/compiler-studio-plan-loop/DISABLE_AUTOSTART`.

**Philosophy:** [li-benchmark-correctness.mdc](../../../.cursor/rules/li-benchmark-correctness.mdc) — correct per spec, fast as possible; **DCE allowed, our harness must verify**.

**Math surface:** explicit shapes only — **no NumPy broadcasting**.

**Loop:** `./scripts/compiler-studio-plan-loop.py` · gates: `./scripts/compiler-studio-plan-gates.sh` · PR [#176](https://github.com/li-langverse/lic/pull/176)
