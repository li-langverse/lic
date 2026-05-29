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

**Done (none of these):** no **G-*** row is **Done** yet. **Closed slices** exist inside **Partial** rows (e.g. P-linalg closed specimens, static `ensures` witnesses).

| ID | Status | What remains |
|----|--------|----------------|
| **G-lean** | Partial | **Tier B (default when lake installed):** `lic build` runs `lake build AutoVC` (typecheck only; `--no-lean-verify` opt-out). **Strict** open goals: `--strict-lean`. Open obligations: fail unless `--allow-open-vc` (CLI only; env bypass removed). **`LiArray`** + fib/recursive call-site + parallel `_par*` VCs typecheck. **Still open:** `sqrt_open_bound` (P-float; `Float.abs` Prop, no `_proved` — `sqrt_open_bound_contract_tier.sh`); `mat2_at2_eval` trusted vs MIR `@` (semantic closed in `Discharge.lean`) |
| **G-vc** | Partial | Float/`abs` ensures; opaque `vec3_dot`-style returns; loop implementations vs closed-form `ensures`. **`sqrt_open_bound`:** real `Float.abs` Prop, open until P-float (`sqrt_open_bound_contract_tier.sh`); `lic check` passes, `lic build` fails without downgrade |
| **G-par** | Partial | AST `policy_module` rejects missing disjoint, false `disjoint_row` (`grid[0][0]`), mut capture, borrow-in-par on **`parallel for` only**; **`disjoint_elem` + `buf[0]`** (`policy_disjoint_elem_soundness.sh`); **`@parallel` on `for` bypasses capture/borrow policy** (`parallel_decorator_policy_capture_gap.sh`); Lean proofs open |
| **G-dec** | Partial | Decorator elaboration to MIR; **7d-b** `@vectorized` on `for` → `ArraySimdScope`; `@parallel` on plain `for` stays serial (`parallel_decorator_for_elaboration_gap.sh`); parallel policy (disjoint, capture, borrow) not applied to decorated `for` (`parallel_decorator_policy_capture_gap.sh`) |
| **G-math** | Partial | **Closed slice (tier-1):** `matmul_naive`, `horner_pure_li` ≤1.2× C++ (`check-tier1-li-vs-cpp.sh`, loop matmul + FMA horner). **Closed slice:** full 2×2 float `@` Lean Prop (`linalg_mat2_at2_float_closed`, `mat2_at2_float_spec`). **Closed slice:** `linalg_dot4_float_closed` (prelude `dot`), `linalg_mat2_callproc_float_closed`, prelude `norm`/`axpy`/**, IKJ `ArrayMatMul2DF64` enforced only with `LI_TIER1_PERF_STRICT=1` (`check-tier1-li-vs-cpp.sh` reports gaps by default). **Closed slice:** prelude `norm`, `axpy`, same-length `**`, scalar×array, `math_linalg/reductions/`, loop-dot witness, P-linalg corpus |
| **G-bnd** | Partial | No `li_bounds_fail` in codegen today (`emit.cpp` declares only); refinement indices use `inbounds` GEP without Lean bounds VCs (`index_refinement.li` → `vc_get_requires_0 := True`) — `bounds_refinement_lean_gap.sh` |
| **G-def** | Partial+ | Cross-module method privacy proofs; virtual dispatch deferred |
| **G-oop** | Partial | Lean `ensures` on methods; trait laws in kernel |
| **G-math-syn** | Partial | `for` / `range` surface |
| **G-stdlib** | Partial | Full workspace cycle + seal edge cases |
| **G-narrow** | Partial | Proved width narrowing (beyond `cast[` reject) |
| **G-async** | Partial | `await` + structured concurrency proofs |
| **G-net** | Partial | Net effect codegen + proofs; **w0-bytes-io:** `raises Net` propagation + `check-w0-bytes-io.sh` |
| **G-trust** | Partial | `trusted.lean` Net v1 axioms + accepted trusted-net RFC; `Core.lean` / `MIR.lean` still planned |
| **G-ann** | Missing | PEP 649 deferred annotations |
| **G-gpu** | Missing | `@gpu` address-space proofs + codegen |
| **G-meta** | Missing | Compiler ↔ Lean equivalence (research) |
| **G-authz** | Missing | Capability / IDOR (OS phase) |
| **G-test-verify** | Partial | Split `verify_ok` vs `prove_lean_ok` in manifest |
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
| **G-lean** | Lean 4 gate | `lic build` fails if any VC open | **Partial** — static witnesses + **P-linalg** closed corpus (#151); `sqrt_open_bound` intentional open (`Float.abs` Prop, no `_proved`); kernel not default gate | **2f** | `contracts_discharge_corpus.sh`, `sqrt_open_bound_contract_tier.sh`, `discharge_linalg_int_lean.sh`, `check-autovc-open-goals.sh` |
| **G-vc** | VC generation | Contracts → proof obligations | **Partial** — auto `_proved` + `lic verify witnessed_ensures=` / `mir_return_linked=`; **E0303** rejects `ensures true` on value returns; **call-site callee `requires`** + **refinement param VCs** in `AutoVC.lean` (literal / const-local discharge); `sqrt_open_bound` float `abs` open (not `True` stub) | **2e** | `vc_emit_lean.cpp`, `vc_witness.cpp`, `call_requires.cpp`, `contracts_discharge_corpus.sh`, `sqrt_open_bound_contract_tier.sh` |
| **G-par** | `parallel for` safety | Proved iteration independence | **Partial** — AST `check_module_policies` on **`ParallelFor` only**; `disjoint_row` + `grid[0][0]` rejected; **`disjoint_elem` + `buf[0]` hole**; mut capture / borrow guards **not** on `@parallel` `for` | **7b**, **7d-c** | `race_shared_memory/`, `policy_disjoint_elem_soundness.sh`, `parallel_decorator_policy_capture_gap.sh`, `decorator_exploits` |
| **G-stdlib** | Prelude / std seal | User cannot shadow builtin or `std/` names | **Partial** — `check_stdlib_seal` + `resolve_imports` for `std.*` / workspace; cycle detect at load | **4s** | `li-tests/stdlib_seal/`, `li-tests/modules/` |
| **G-dec** | Execution decorators | Static elaboration; reserved names; no runtime | **Partial** — parse + policy + `MirFn.decorators`; **7d-c** `@vectorized` on `for` → `ArraySimdScope` (#150); `@parallel` on `for` does not lower to `OmpParallelFor`; parallel policy guards skip `Stmt::For` (`policy_module.cpp:171-172`, `200-203`) | **7d** | `decorator_exploits/`, `decorators/`, `parallel_decorator_for_elaboration_gap.sh`, `parallel_decorator_policy_capture_gap.sh` |
| **G-math** | Math / `A @ B` | Shape errors at compile time; no user `simd(...)` | **Partial** — 1d/2d `@` lowering + **P-linalg** proof corpus (`linalg_*_closed.li`, loop dot open) | **2i**, **7e**, **2f** | `li-tests/math_linalg/`, `li-tests/contracts_verify/linalg_*` |
| **G-bnd** | Bounds in release | No reliance on `li_bounds_fail` for proved indices | **Partial** — typecheck rejects raw `int` index; **refinement** params compile but AutoVC `True` + no runtime guard (`bounds_refinement_lean_gap.sh`) | **2e**, **3** | `index_refinement.li`, `emit.cpp:1275`, `vc_emit_lean.cpp:550-551` |
| **G-def** | `def` / `object` / visibility | Handbook surface | **Partial+** — methods/`self`, `private def`, MIR in-out write-back (**2j-a/b/c**); inheritance/traits open (**2j-d–f**) | **2j** | `li-tests/encapsulation/`, `composable/import_physics_runtime.li` |
| **G-oop** | Full OOP | Methods, traits, inheritance, cross-module encapsulation | **Partial** — **2j-a…f** surface done; Lean `ensures` on methods / trait laws open | **2j** | `li-tests/encapsulation/trait_*.li`, `method_call_requires_*.li` |
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
| Out-of-bounds | Compile-time proof | Typecheck blocks raw `int` index; **no** `li_bounds_fail` emitted yet — refinement Lean VCs stubbed |
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
| `li-tests/contracts_verify/` | **Partial** — `sqrt_contract` float Props; **P-linalg** closed int dot/sum/matmul entry; `linalg_dot4_int_loop_open` intentional open |
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
