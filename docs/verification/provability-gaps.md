# Provability gaps (current compiler)

**Last updated:** 2026-05-21  
**Audience:** contributors, package authors, anyone relying on `lic build` as a proof certificate  

Li’s **north star** is: user logic is proved before ship; runtime failures for proved programs → **~0%**. That is the **target**, not a complete description of **`lic` today**.

**Policy vs implementation:** [Strict by default](../ecosystem/strict-by-default.md) — there is **no optional provability** by default. Rows below are **compiler maturity** (what is not wired yet), **not** permission for users to turn proof off without an explicit `li.toml` / documented downgrade.

This page is the **honest inventory** of what is **not** fully proved or not yet wired. When a gap closes, update this file in the **same PR** as the implementation.

**Related:** [Verification overview](overview.md) · [Master plan — Doc phase & compiler task map](../superpowers/plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting) · [Trusted axioms](../semantics/README.md)

---

## Summary (read this first)

| | Target (spec) | Today (`lic` on `dev`) |
|---|----------------|-------------------------|
| **`lic build` = proof certificate** | Lean 4 kernel closes all VCs | **No** — parse, policy strings, typecheck, borrow, LLVM link only |
| **`lic check`** | Fast IDE feedback | **Yes** — no Lean, not a certificate |
| **Parallel disjointness** | Lean + structured proofs | **Partial** — substring heuristics in `policy.cpp` |
| **Index bounds (release)** | Refinement / proved → no user traps | **Partial** — MIR/runtime paths still evolving |
| **Decorators (`@parallel`, …)** | Compile-time elaboration + proofs | **Partial** — parse + policy (7d-a/e); no MIR lowering yet |
| **Math / linalg surface** | Static shapes, compile-time lowering | **Partial** — shape tests + **P-linalg** closed VCs (2i / 7e) |
| **Zero user runtime errors** | All above + 2f gate | **In progress** — see table below |

---

## Still open (report every session)

**Done:** **G-test-verify** (manifest `prove_lean_ok`). **Closed slices** inside **Partial** rows (e.g. P-linalg closed specimens, static `ensures` witnesses). All other **G-*** rows remain **Partial** or **Missing**.

| ID | Status | What remains |
|----|--------|----------------|
| **G-lean** | Partial | **Tier B** when lake installed; **closed slice:** `sqrt_open_bound` via `Li.Discharge.sqrt_open_bound_spec` (trusted libm); kernel not universal |
| **G-vc** | Partial | Float/`abs` ensures; opaque `vec3_dot`-style returns; loop implementations vs closed-form `ensures` |
| **G-par** | Partial | AST `policy_module` rejects missing disjoint, false `disjoint_row`, mut capture, borrow-in-par; Lean proofs open |
| **G-dec** | Partial | Decorator elaboration to MIR; `decorator_exploits` proofs |
| **G-math** | Partial | **Closed slice (length-1 broadcast):** `broadcast_len1_{add,mul,pow}_*.li`; `broadcast_invalid_len2_vs_len4.li` + `elementwise_len_mismatch.li` compile_fail. **Closed slice (reductions shape):** `reductions/{sum_non_array,dot_len_mismatch}.li` compile_fail. **Closed slice (tier-1 perf):** `matmul_naive`, `horner_pure_li` ≤1.2× C++. **Closed slice:** 2×2 float `@` Prop; P-linalg int corpus; loop dot open |
| **G-bnd** | Partial | Release path without `li_bounds_fail` for proved indices |
| **G-def** | Partial+ | Cross-module method privacy proofs; virtual dispatch deferred |
| **G-oop** | Partial | **Closed slice:** method call-site `requires` + int-return `ensures` in `contracts_verify/` (`discharge_method_*_lean.sh`); trait laws / `old(self.field)` open |
| **G-math-syn** | Partial | `for` / `range` surface |
| **G-stdlib** | Partial | **Closed slice:** import-graph seal + `import_cycle` (`shadow_echo_via_import.li`, `import_cycle_a.li`); re-export override open (8a) |
| **G-narrow** | Partial | Proved width narrowing (beyond `cast[` reject) |
| **G-async** | Partial | `await` + structured concurrency proofs |
| **G-net** | Partial | Net effect codegen + proofs; **w0-bytes-io:** `raises Net` propagation + `check-w0-bytes-io.sh` |
| **G-trust** | Partial | `trusted.lean` Net v1 axioms + accepted trusted-net RFC; `Core.lean` / `MIR.lean` still planned |
| **G-ann** | Missing | PEP 649 deferred annotations |
| **G-gpu** | Missing | `@gpu` address-space proofs + codegen |
| **G-meta** | Missing | Compiler ↔ Lean equivalence (research) |
| **G-authz** | Missing | Capability / IDOR (OS phase) |
| **G-test-verify** | **Done** | `prove_lean_ok` in `run_all.sh`; 14 closed `contracts_verify` specimens |
| **G-hw** | Axiomatic | FP/hardware model limit (documented, not closable) |
| **G-wrong-spec** | Social | User theorem quality (not tool-closable) |

**Proof backlog still open:** **P-refine**, **P-ensures-witness**, **P-float**, **P-linalg** (float `@` Props; full matmul), **P-par**, **P-dec**, **P-bnd**, **P-http**, **P-narrow**, **P-meta** — see [proof-corpus-roadmap](proof-corpus-roadmap.md). **P-linalg partial:** closed dot/sum/matmul-entry + **loop dot** (`linalg_dot4_int_loop_open`, `dot4_int_loop_eval_spec`); open float `vec3_dot`, 2D CallProc.

!!! warning "Do not overclaim in docs or packages"
    Until **Phase 2f** lands, saying “`lic build` proves your program in Lean” is **aspirational**. Prefer: “`lic build` runs the current static gate; see [provability gaps](provability-gaps.md).”

---

## Gap register

Status legend: **Missing** · **Stub** · **Partial** · **CI only** · **Done**

| ID | Area | Spec / promise | Current state | Phase | How we know |
|----|------|----------------|---------------|-------|-------------|
| **G-lean** | Lean 4 gate | `lic build` fails if any VC open | **Partial** — Tier B `lake build AutoVC` when installed; **closed slice:** 14× `prove_lean_ok` corpus; `sqrt_open_bound` intentional open; kernel not universal certificate | **2f** | `discharge_trivial_lean.sh`, `discharge_linalg_int_lean.sh`, `contracts_discharge_corpus.sh`, `check-autovc-open-goals.sh`, `li-tests/run_all.sh` `prove_lean_ok` |
| **G-vc** | VC generation | Contracts → proof obligations | **Partial** — **closed slice:** call-site `requires`, const-local discharge, E0303/E0304/E0305; open: float `abs`, opaque returns | **2e** | `vc_emit_contracts.sh`, `mir_vc_witness.sh`, `discharge_caller_requires_lean.sh`, `discharge_caller_requires_local_lean.sh`, `contracts_discharge_corpus.sh`, `prove_reject/weak_ensures_true.li` |
| **G-par** | `parallel for` safety | Proved iteration independence | **Partial** — **closed slice:** 6× `compile_fail` + `good_disjoint_parallel.li` `verify_ok`; Lean disjoint proofs open | **7b**, **7d-c** | `li-tests/race_shared_memory/`, `decorator_exploits/missing_disjoint_at_parallel.li`, `run_all.sh` suite `race_shared_memory` |
| **G-stdlib** | Prelude / std seal | User cannot shadow builtin or `std/` names | **Partial** — **closed slice:** `check_stdlib_seal` on entry + each resolved import; `import_cycle` at load; workspace `std.*` / path deps; re-export override open (**8a**) | **4s** | `li-tests/stdlib_seal/` (6 compile_fail incl. `shadow_echo_via_import.li`), `li-tests/modules/import_cycle_a.li` |
| **G-dec** | Execution decorators | Static elaboration; reserved names; no runtime | **Partial** — **closed slice:** 4× `decorator_exploits` `compile_fail`; `@vectorized` on `for` (`vectorized_for_scope_ok.li`); `@parallel` MIR elaboration open | **7d** | `li-tests/decorator_exploits/`, `li-tests/decorators/vectorized_for_scope_ok.li`, `run_all.sh` suites `decorator_exploits`, `decorators` |
| **G-math** | Math / `A @ B` | Shape errors at compile time; no user `simd(...)` | **Partial** — **closed slice:** 9× `prove_lean_ok` linalg + `discharge_linalg_int_lean.sh`; `math_linalg/` compile tests; tier-1 `tier1_li_vs_cpp.sh` | **2i**, **7e**, **2f** | `li-tests/math_linalg/`, `li-tests/contracts_verify/linalg_*_closed.li`, `li-tests/tooling/discharge_linalg_int_lean.sh`, `li-tests/tooling/tier1_li_vs_cpp.sh` |
| **G-bnd** | Bounds in release | No reliance on `li_bounds_fail` for proved indices | **Partial** — architecture lists MIR bounds; not full refinement | **2e**, **3** | [Architecture](../architecture/overview.md); codegen paths |
| **G-def** | `def` / `object` / visibility | Handbook surface | **Partial+** — methods/`self`, `private def`, MIR in-out write-back (**2j-a/b/c**); inheritance/traits open (**2j-d–f**) | **2j** | `li-tests/encapsulation/`, `composable/import_physics_runtime.li` |
| **G-oop** | Full OOP | Methods, traits, inheritance, cross-module encapsulation | **Partial** — **2j-a…f** surface + **P-oop partial:** folded method call-site `requires` + method `ensures` witnesses; trait laws / `old(self.field)` open | **2j** | `method_call_requires_*.li`, `method_ensures_return_ok.li`, `encapsulation/trait_*.li` |
| **G-math-syn** | Python-math (`**`, `for`, …) | Ergonomic surface | **Partial** — `%`, `//`, `**` on `int`; `for`/`range` open | **2h** | `li-tests/math_syntax/` |
| **G-ann** | Deferred annotations (PEP 649) | Lazy resolve at check | **Missing** — shown in pipeline diagram as planned | **4** | Not in compiler tree |
| **G-gpu** | `@gpu` / device buffers | Separate address space proofs | **Missing** | **3+**, **7d** | Spec Phase 3+ |
| **G-async** | `@async` / `raises Async` | Structured concurrency proofs | **Partial** — `@async` requires `raises Async`; await not parsed | **2+**, **7d** | `li-tests/effects/` |
| **G-net** | `raises Net` | Trusted syscall surface | **Partial** — effect propagation + `trusted.lean` v1 TcpListen/TcpConn; C seam in `li_rt_net.c` | **H**, **2f** | `li-tests/effects/net_*.li`, `li-tests/net_trusted/`, `check-w0-bytes-io.sh` |
| **G-trust** | Trusted base growth | Only `trusted.lean` | **Partial** — Net axioms + [trusted-net RFC](../superpowers/specs/2026-05-16-li-trusted-net-rfc.md); `Core.lean` / `MIR.lean` **planned** | **2f** | [semantics/README.md](../semantics/README.md) |
| **G-meta** | Compiler correctness | C++ compiler ≡ Lean semantics | **Missing** (research) | long-term | Not started |
| **G-hw** | Hardware / FP | Model vs IEEE / CPU bugs | **Axiomatic** | — | Documented limit |
| **G-wrong-spec** | User contracts | Correct theorem | **Social** — tool cannot fix | — | Review culture |
| **G-narrow** | Narrowing conversions | Ariane-class truncations rejected without proof | **Partial** — policy rejects `cast[`; width types + proved narrowing pending | **2e** | `historic_ariane5_narrowing.li` |
| **G-authz** | Capability / IDOR | Object capabilities in OS services | **Missing** | OS phase | `historic-bugs.toml` firefly-iii-idor |
| **G-test-verify** | Manifest honesty | `verify_ok` vs Lean QED | **Done** — `prove_lean_ok` outcome; 14 closed `contracts_verify` rows | **2f** | `li-tests/run_all.sh`, `li-tests/manifest.toml`, `contracts_discharge_corpus.sh` |

---

## `lic build` today (actual pipeline)

What **`lic build`** runs **now** (see `compiler/lic/main.cpp`):

1. `check_source_policies()` — string/heuristic policy  
2. `parse_module()`  
3. `typecheck_module()` + borrow  
4. `compile_module()` → MIR → LLVM → link `li_rt`  
5. `write_vcs_lean()` → `build/generated/AutoVC.lean` (typed `Prop` obligations)  

**`lic verify --lean`**: VC counts + `lake build` on `docs/semantics` — see `compiler/verify/`.

What **`lic build`** does **not** run yet (unless Lean 4 installed and not `--no-lean-verify`):

- Lean 4 kernel discharge of non-trivial ensures  
- Lean 4 kernel as default hard gate  
- Decorator elaboration  
- Math-shape checking beyond ordinary types  

```mermaid
flowchart LR
  subgraph today [lic build today]
    pol[policy.cpp heuristics]
    par[parse]
    tc[typecheck + borrow]
    vc[AutoVC.lean Props]
    mir[MIR + LLVM]
    pol --> par --> tc --> vc
    tc --> mir
  end
  subgraph missing [not wired]
    lean[Lean kernel discharge]
    dec[decorator elaborate]
  end
  vc -.->|Phase 2f| lean
  par -.->|Phase 7d| dec
  dec -.-> mir
```

---

## Runtime vs compile-time (honest)

| Mechanism | Intended end state | Today |
|-----------|-------------------|--------|
| Type / borrow errors | Compile-time only | **Mostly** at typecheck |
| `parallel for` races | Compile-time reject | **Heuristic** policy + tests |
| Out-of-bounds | Compile-time proof | **May** still hit `li_bounds_fail` in debug paths |
| Decorators | Never interpreted at run time | **N/A** — not executed; not elaborated yet |
| `li_panic` / contract fail | No user path in proved release | **Runtime** hooks exist in `li_rt` |
| OpenMP | Native threads | **Runtime** library (not user logic validation) |
| Fuzz / TSan | Find compiler bugs | **CI optional** — not user proof |

**Goal unchanged:** shrink the right-hand column until user logic never depends on the runtime column for correctness.

---

## Tests vs proofs

| Suite | What it proves |
|-------|----------------|
| `li-tests/race_shared_memory/` | Policy + typecheck **reject** bad parallel patterns (not Lean) |
| `li-tests/decorator_exploits/` | **Planned** — reserved names, macro hijack (7d-e) |
| `li-tests/math_linalg/` | **Partial** — 1d/2d `@`, element-wise, matmul compile tests (2i/7e) |
| `li-tests/contracts_verify/` | **Partial** — 14× `prove_lean_ok` closed corpus; `sqrt_open_bound` intentional open (`verify_open_ok`); refinements on `verify_ok` |
| `li-tests/tooling/discharge_linalg_int_lean.sh` | P-linalg closed specimens → zero open AutoVC goals |
| `li-tests/tooling/vc_emit_contracts.sh` | `sqrt_contract` AutoVC uses `≥` / `Float.abs`, not `True` stubs |
| `li-tests/tooling/discharge_trivial_lean.sh` | `discharge_trivial.li` → zero open Prop goals + `lake build` when Lean installed |
| `li-tests/prove_reject/` | Rejection of forbidden constructs (where present) |
| Fuzz (`compiler/fuzz/`) | Parser robustness — **not** end-to-end proof |

Passing **`./li-tests/run_all.sh`** means the **current** gate holds — not the full spec gate.

**Corpus inventory, run commands, and proof backlog for the master plan:** [proof-corpus-roadmap.md](proof-corpus-roadmap.md).

---

## Documentation that must stay aligned

When editing handbook pages, do **not** imply features beyond this register without a “**Status:** implemented” note.

| Doc | Alignment action |
|-----|------------------|
| [Contracts and proofs](../language/contracts-and-proofs.md) | Points here for `lic build` vs Lean |
| [Build pipeline](../compiler/build-pipeline.md) | Lean stage marked *planned* |
| [Why provable](../compiler/why-provable.md) | Links here under honest limits |
| [Language overview](../language/overview.md) | “Status honesty” links here |
| [SIMD and parallel](../language/simd-parallel.md) | Note heuristic disjoint until 7d-c |
| Decorator / math spec stubs | Say “planned” until gaps closed |

---

## Closing gaps (priority)

Rough order from [master plan](../superpowers/plans/2026-05-14-li-master-plan.md) § *Compiler tasks vs proof gaps*:

1. **2e** — VC generation (**G-vc**)  
2. **2f** — Lean 4 in `lic build` (**G-lean**, **G-vc**, **G-trust**)  
3. **7b / 7d-c** — structured `disjoint=` (**G-par**)  
4. **7d** — decorator elaboration (**G-dec**)  
5. **2i / 7e** — math surface (**G-math**)  

**Documentation:** Phase **Doc** (Doc-a … Doc-e) in the master plan — update this file and handbook pages in the **same PR** as each compiler row moves to **Partial** or **Done**.


| **G-trust** | Partial+ | **T-GetElem** in `Core.lean`; `MIR.lean` preservation open |
| **G-trust** | Trusted base growth | Only `trusted.lean` | **Partial+** — **T-GetElem** (`typing_getElem`) in `Core.lean`; `MIR.lean` preservation **planned** | **2f** | `docs/semantics/Core.lean`, [semantics/README.md](../semantics/README.md) |
