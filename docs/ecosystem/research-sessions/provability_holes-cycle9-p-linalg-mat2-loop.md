# Research session — provability_holes cycle 9 (P-linalg mat2 loop witness + G-test-verify)

**Run:** `proof_gap_researcher-2026-05-30-mat2-loop-witness`  
**North star:** provable · **PH:** 2e, 2f  
**Focus:** **G-vc**, **G-test-verify**, **G-math** (P-linalg loop backlog)

## 1. Compiler / semantics gaps

- `witness_mat2_int_at2_spec_impl` only matches `return A @ B` (`vc_witness.cpp:415–424`), not IKJ loop bodies.
- Dot loops have `witness_dot4_int_loop_impl` (`vc_witness.cpp:459+`); **no** `witness_mat2_*_loop` analogue.
- New specimen `linalg_mat2_int_loop_no_witness.li`: float IKJ nest; AutoVC `ensures` is a real `Prop` without `_proved` (see generated `vc_mat2_loop_entry00_ensures_0`).
- **Codegen note:** int nested-array variant hit LLVM SSA / call ABI errors; float variant compiles — int 2D loop lowering still fragile (**G-math**).

## 2. Contract gaps

- **P-linalg:** closed slices cover `@`, prelude dot, dot4 loop witness; **open:** loop matmul entry ≡ closed `ensures` (this session).
- `sqrt_open_bound.li`: build fails without `--allow-open-vc` (repro below); manifest correctly uses `verify_open_ok`.

## 3. Trusted surface

- No `trusted.lean` edits. `mat2_at2_eval` remains definitional in `Discharge.lean:46–58` (not an axiom).
- Loop specimen discharges **neither** via `Li.Discharge.mat2_at2_*` (grep AutoVC — no `Discharge.mat2` on loop file).

## 4. External trust boundaries

- Full matmul loop ≡ spec proof deferred to human **P-linalg** / **G-meta** (MIR preservation), outside this agent pass.
- `trusted.lean` Net axioms unchanged (**G-trust**).

## 5. Evidence pack

| Item | Location |
|------|----------|
| Loop specimen | `li-tests/contracts_verify/linalg_mat2_int_loop_no_witness.li` |
| Open-VC guard | `li-tests/tooling/p_linalg_mat2_loop_witness_gap.sh` |
| Manifest tier guard | `li-tests/tooling/verify_ok_manifest_tier_gap.sh` |
| Mat2 `@` witness gate | `compiler/verify/vc_witness.cpp:415–424` |
| Dot loop witness | `compiler/verify/vc_witness.cpp:459–474` |
| G-test-verify register | `docs/verification/provability-gaps.md:54`, `proof-corpus-roadmap.md:16` |
| `run_all` verify_ok | `li-tests/run_all.sh:91–98` |

### Repro commands (2026-05-30)

```bash
cd lic
./li-tests/tooling/p_linalg_mat2_loop_witness_gap.sh          # exit 0
./li-tests/tooling/verify_ok_manifest_tier_gap.sh            # exit 0
./li-tests/tooling/contracts_discharge_corpus.sh             # exit 0 (includes new guards)
lic check li-tests/contracts_verify/linalg_mat2_int_loop_no_witness.li   # exit 0
lic build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null      # exit 1 (open VC)
lic build --allow-open-vc li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null  # exit 0
lic build li-tests/contracts_verify/linalg_mat2_at2_float_closed.li -o /dev/null
scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean           # exit 0 (closed)
```

## Hypothesis outcomes

- **HYPOTHESIS: verified** — IKJ loop matmul entry has no static witness; AutoVC `vc_mat2_loop_entry00_ensures_0` stays open | evidence: `p_linalg_mat2_loop_witness_gap.sh`, `vc_witness.cpp:415–424` vs `459+`
- **HYPOTHESIS: verified** — `witness_mat2_*` only applies to `return A @ B`, not loop implementations | evidence: `vc_witness.cpp:417–418` (`BinOp::MatMul` on return)
- **HYPOTHESIS: verified** — manifest `verify_ok` runs `lic build` only, not `discharge_linalg_int_lean.sh` | evidence: `verify_ok_manifest_tier_gap.sh`, `run_all.sh:91–98`
- **HYPOTHESIS: verified** — `sqrt_open_bound` fails `lic build` without `--allow-open-vc` | evidence: command above, `contracts_discharge_corpus.sh:19–22`
- **HYPOTHESIS: falsified** — int nested-array IKJ specimen builds today | evidence: LLVM "Instruction does not dominate" / call signature mismatch on int variant (float specimen used instead)
- **HYPOTHESIS: deferred** — MIR `ArrayMatMul2DF64` refines `mat2_at2_eval` | evidence: cycle 2 whitepaper; no `MIR.lean` preservation lemma on `main`
