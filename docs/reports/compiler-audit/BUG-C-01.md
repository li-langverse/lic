# BUG-C-01 — dot4 int loop Lean discharge

**Gap script:** `li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh`  
**Status:** **Resolved** (2026-06-01)  
**Fix:** [PR #696](https://github.com/li-langverse/lic/pull/696) — `vc_emit_lean.cpp` wires `Li.Discharge.dot4_int_spec` / `dot4_int_loop_eval_spec`; loop specimen `linalg_dot4_int_loop_open.li` discharges without `Prop := True` stubs.

## Summary (from gap script)

P-linalg / G-vc (#472): fixed-bound dot loop witness wires `Li.Discharge.dot4_int_spec`, `dot4_loop_eval`, and `dot4_int_loop_eval_spec` (mirror `mat2_at2_float_spec`).

## Verification

```bash
bash li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh
```

Expect **PASS** when `build/compiler/lic/lic` exists.

## Agent notes

Do not revert catalog downgrade on `linalg_dot4_int_loop_open` without re-running the gap script. If regression fails, file a new BUG-C row — do not patch `compiler/` from agent goals.