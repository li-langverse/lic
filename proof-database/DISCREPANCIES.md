# Proof database — discrepancies

**Generated:** 2026-05-29

## Taxonomy

| Kind | Meaning |
|------|---------|
| `missing_lemma` | Catalog cites absent Lean name |
| `open_vc` | Claimed proved but placeholder/sorry |
| `spec_drift` | Specimen/TOML vs Lean |
| `trusted_axiom` | Li.Trusted.* |
| `hardware_axiom` | G-hw FP limit |

## Register

| ID | Kind | Gap | Resolution |
|----|------|-----|------------|
| `disc-G-lean-autovc-strict-missing-lean` | `missing_lemma` | G-lean | open |
| `disc-P-float-sqrt-open-bound-open-vc` | `open_vc` | G-lean | intentional |
| `disc-P-linalg-dot4-int-closed-missing-lean` | `missing_lemma` | G-math | open |
| `disc-g-hw-float-model` | `hardware_axiom` | G-hw | wontfix |
| `disc-g-lean-universal-autovc-open` | `open_vc` | G-lean | intentional |
| `disc-g-par-lean-disjoint-missing` | `missing_lemma` | G-par | pending |
| `disc-linalg-loop-manifest-drift` | `spec_drift` | G-vc | intentional |
| `disc-mat2-trusted-vs-mir` | `spec_drift` | G-trust | pending |
| `disc-sqrt-open-bound-missing-spec` | `missing_lemma` | G-lean | open |
| `disc-std_add_comm-open-vc` | `open_vc` | — | intentional |
| `disc-std_mul_assoc-open-vc` | `open_vc` | — | intentional |
| `disc-std_triangle_ineq_scalar-open-vc` | `open_vc` | G-hw: explicit trusted axiom (float order not in Core slice) | intentional |
| `disc-trusted-IO` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-Net` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-float_abs_triangle` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-li_rt_sqrt` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-li_rt_sqrt_square_bound` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-poll_event` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-present_frame` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-tcp_accept_stub` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-tcp_close_stub` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-tcp_listen_stub` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-tcp_recv_stub` | `trusted_axiom` | G-trust | wontfix |
| `disc-trusted-tcp_send_stub` | `trusted_axiom` | G-trust | wontfix |
