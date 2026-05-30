# Provability holes — cycle 10 (G-net trusted proxy seam Net effect omission)

**Run:** `proof_gap_researcher-1780118603001` · **Date:** 2026-05-30  
**Goal:** `provability_holes` · **Focus:** **G-net**, **G-trust** · **PH-2f, PH-H**  
**north_star_fit:** provable pillar — effect tracking on trusted Net seam must match C I/O reality

## Executive summary

- **34** `httpd_li_proxy_*` / related epoll seam procs in `std/runtime/seam.li` declare **no** `raises Net`; C handlers call `recv`/`send`/`httpd_proxy_*` (`runtime/li_rt_net.c:6227+`).
- **`tcp_listen`** correctly forces caller `raises Net` (`borrowck.cpp:469`, `seam_missing_net.li` → compile_fail).
- **Proxy epoll gap specimen** passes `lic check` without `raises Net` — effect system silently hides Net from callers.
- **No `trusted.lean` edits** (human-approved RFC only).
- CI guard: `li-tests/tooling/seam_proxy_net_effect_gap.sh` wired into `scripts/check-w0-bytes-io.sh`.

## Digest sections

### 1. Compiler / semantics gaps

| ID | Finding |
|----|---------|
| **G-net** | Net effect propagation is **partial** — only extern procs with explicit `raises Net` in seam force caller annotation. |
| **G-meta** | Deferred — no compiler↔Lean equivalence for effect rows. |

### 2. Contract gaps

- Proxy seam uses `ensures true` stubs; no Lean VCs link C recv/send to `Li.Trusted.Net` axioms (**G-vc** partial, out of scope this step).

### 3. Trusted surface

| Surface | State |
|---------|-------|
| `trusted.lean` Net axioms | v1 stubs (`tcp_listen_stub`, …) — unchanged |
| `std/runtime/seam.li` | **Gap:** 34 proxy/epoll procs omit `raises Net` despite socket I/O in C |
| `seam_missing_net.li` | Control — tcp_listen path enforced |

### 4. External trust boundaries

- **Human decision:** audit full proxy seam manifest + add `raises Net` (or split pure accessors vs I/O procs) in RFC-tracked PR touching `seam.li` + `trusted-extern-manifest` — **not** agent-edited without review.

### 5. Evidence pack

| Item | Location |
|------|----------|
| Gap specimen | `lic/li-tests/net_trusted/seam_proxy_epoll_missing_net.li` |
| Control | `lic/li-tests/net_trusted/seam_missing_net.li` |
| C I/O | `lic/runtime/li_rt_net.c:6227` (`httpd_li_proxy_client_epoll_i` → `httpd_proxy_client_handler`) |
| Seam omission | `lic/std/runtime/seam.li:315-320` (no `raises Net`) |
| Effect check | `lic/compiler/types/borrowck.cpp:469` |
| CI guard | `lic/li-tests/tooling/seam_proxy_net_effect_gap.sh` |
| Register | `lic/docs/verification/provability-gaps.md` **G-net**, **G-trust** |

**Repro:**

```bash
cd lic
LIC=$(./scripts/resolve-lic.sh)
./li-tests/tooling/seam_proxy_net_effect_gap.sh   # exit 0 while gap open
$LIC check li-tests/net_trusted/seam_proxy_epoll_missing_net.li  # exit 0 (gap)
$LIC check li-tests/net_trusted/seam_missing_net.li 2>&1 | grep "raises Net"  # exit 1 (control)
```

## Hypothesis outcomes

- **HYPOTHESIS: verified** — `httpd_li_proxy_client_epoll_i` is callable without caller `raises Net` | evidence: `lic check li-tests/net_trusted/seam_proxy_epoll_missing_net.li` exit 0; C recv at `li_rt_net.c:6246`
- **HYPOTHESIS: verified** — `tcp_listen` Net propagation still enforced (control) | evidence: `seam_missing_net.li` → `borrowck.cpp:469` error
- **HYPOTHESIS: falsified** — all 34 proxy procs are pure accessors with no socket syscalls | evidence: `httpd_li_proxy_finish_drain_i` calls `recv()` at `li_rt_net.c:6246`
- **HYPOTHESIS: deferred** — Lean Net monad models proxy handler effects | evidence: `trusted.lean` has v1 listen/accept/send stubs only; no proxy lemmas

## Recommended issues/PRs

1. **lic:** `[G-net] Add raises Net to httpd_li_proxy_* seam procs with socket I/O` — labels: `provability`, `G-net`, `httpd`
2. **lic:** `[G-trust] Trusted-extern manifest audit — proxy seam vs C syscall surface` — labels: `security`, `G-trust`
3. **lic:** Retire `seam_proxy_net_effect_gap.sh` when proxy specimens flip to `compile_fail` without Net

## Deferred

- **vec3_dot opaque VC** (cycle 18 branch) — `ensures result == ax * bx + …` uses out-of-scope locals (`packages/li-math/src/lib.li:136`)
- **@parallel on plain for** policy bypass (cycle 8) — merge guard scripts from research branch
- **P-linalg loop matmul witness** (cycle 9) — `witness_mat2_loop_entry00`
