# Provability holes — cycle 10 (disjoint_elem decorator path)

**Agent:** `proof_gap_researcher` · **2026-05-29**  
**north_star_fit:** PH-7b, PH-7d-c — G-par / G-dec

## Focus

Extend cycle 7 (`disjoint_elem` + `buf[0]` on `parallel for`) to **`@parallel(disjoint=disjoint_elem)` on plain `for`**.

## Outcomes

- `false_disjoint_elem_decorator_constant_index.li` passes `lic check` (same hole as `false_disjoint_elem_constant_index.li`).
- `policy_disjoint_elem_soundness.sh` covers both paths.

See benchmarks digest: `proof_gap_researcher-2026-05-29-disjoint-elem-policy.md`.
