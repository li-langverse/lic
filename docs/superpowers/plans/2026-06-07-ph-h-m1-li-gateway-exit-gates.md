# Phase H M1 — li-httpd `.li` gateway exit gates (2e–2f + P0)

> **Issue:** [#18](https://github.com/li-langverse/lic/issues/18) · **Repo:** li-langverse/lic  
> **Vision:** Proof → easy → fast — M1 `.li` ship only after named P0 gates pass; no narrative-only tracker edits  
> **North star fit:** web / agent gateway — **PH-H**, **PH-2e**, **PH-2f**, **G-lean**, **G-vc**, **G-net**, **G-async**  
> **Learned from:** [master plan §Phase H](2026-05-14-li-master-plan.md), [httpd-prerequisites](../../ecosystem/httpd-prerequisites.md), [provability-gaps](../../verification/provability-gaps.md), [li-httpd plan](2026-05-16-li-httpd-plan.md), [#30 exit graph](2026-06-07-ph-h-httpd-m1-blocked-by-exit-graph.md)

## Goal

Satisfy [#18](https://github.com/li-langverse/lic/issues/18) acceptance: an **ordered sub-plan / checklist** in [li-httpd plan](2026-05-16-li-httpd-plan.md) tying Phase **H — M1 `.li`** to the [P0 table](../../ecosystem/httpd-prerequisites.md), explicit **G-*** exit gates (Doc-c), and a **documented downgrade path** when **PH-2e** / **PH-2f** remain **Partial**.

**Docs-only scope** — no compiler or runtime implementation in this plan PR.

## Non-goals

- Marking **G-lean** or **G-vc** **Done** globally ([#32](https://github.com/li-langverse/lic/issues/32) owns T6).
- Implementing M1 runtime parity (`m1-serve-production`, tier5 bench vs nginx) — tracked in [li-httpd plan](2026-05-16-li-httpd-plan.md) parity milestones.
- Weakening `HTTPD_LEAN_GATE_MAX_OPEN` or `--allow-open-vc` to green-wash M1 closure.
- Editing `trusted.lean` without a human-approved issue.

## Implementation gate (hard rule)

**Do not start new M1 `.li` gateway implementation** until:

1. **PH-2e** and **PH-2f** master-plan tracker rows are **Done**, **or**
2. They remain **Partial** with an **explicit documented downgrade** (below) and **T2** httpd Lean slice gates green.

| PH phase | G-* rows | Downgrade when Partial | Still required for M1 `.li` start |
|----------|----------|------------------------|-----------------------------------|
| **2e** (VC generation) | [**G-vc**](../../verification/provability-gaps.md#g-vc) | Call-site `requires`, const-local discharge; closed `http_parse_forward_closed.li` witness | `check-httpd-lean-gate.sh` + `discharge_http_forward_lean.sh` |
| **2f** (Lean on build) | [**G-lean**](../../verification/provability-gaps.md#g-lean), [**G-trust**](../../verification/provability-gaps.md#g-trust) | Bounded open VC (≤ `HTTPD_LEAN_GATE_MAX_OPEN`, default 8) with `--allow-open-vc` on httpd smokes only | Same + `check-httpd-server-lean-gate.sh` before T5 close |

**Honest wording:** P0-lean **pass** = **T2** (httpd slice). **G-lean Done** = **T6** ([#32](https://github.com/li-langverse/lic/issues/32)). See [#30](https://github.com/li-langverse/lic/issues/30) exit-graph plan for T0–T6 tier definitions.

---

## Ordered P0 exit gates (canonical checklist)

Mirrors [httpd-prerequisites](../../ecosystem/httpd-prerequisites.md) — run **in order** before M1 `.li` ship work.

| Order | P0 ID | Work | PH | G-* (Doc-c) | Exit gate (script) | Status (2026-06-07) |
|-------|-------|------|-----|-------------|-------------------|---------------------|
| 1 | **P0-lean** | VC + Lean on `lic build` | **2e**, **2f** | [**G-vc**](../../verification/provability-gaps.md#g-vc), [**G-lean**](../../verification/provability-gaps.md#g-lean), [**G-trust**](../../verification/provability-gaps.md#g-trust) | `check-httpd-lean-gate.sh`, `discharge_http_forward_lean.sh`, `contracts_discharge_corpus.sh` | **Gated (httpd slice)** — bounded open VC |
| 2 | **P0-bytes** | `std` bytes, stringview, Reader/Writer | **4** | [**G-stdlib**](../../verification/provability-gaps.md#g-stdlib) (coverage) | `check-w0-bytes-io.sh` | **Shipped** |
| 3 | **P0-net** | `raises Net`, trusted syscall RFC | **H**, **2f** | [**G-net**](../../verification/provability-gaps.md#g-net), [**G-trust**](../../verification/provability-gaps.md#g-trust) | `li-tests/net_trusted/`, net slice in `check-w0-bytes-io.sh` | **Shipped** |
| 4 | **P0-async** | async/await + epoll/kqueue | **H**, **7d** | [**G-async**](../../verification/provability-gaps.md#g-async) | `check-w1-async-reactor.sh`, tier5 `tcp_echo` | **Shipped** |
| 5 | **P0-http** | HTTP/1.1 parser proofs | **H** | [**G-vc**](../../verification/provability-gaps.md#g-vc) (P-http backlog) | `http_parse_forward_closed.li`, Li reactor FSM next | **Partial** |

**Aggregate P0 pass (T1):** rows 1–4 ≥ **Gated** or **Shipped**; row 5 may stay **Partial** for config/oracle M1 but blocks full Li reactor parity.

---

## M1 `.li` ship exit checklist (after P0)

From [li-httpd plan](2026-05-16-li-httpd-plan.md) ↔ `scripts/httpd-plan-gates.sh`:

| Step | Todo / milestone | Gate command | G-* touchpoint |
|------|------------------|--------------|----------------|
| 1 | `w0-lean-gate` | `check-httpd-lean-gate.sh` | **G-lean**, **G-vc** (httpd slice) |
| 2 | `w0-bytes-io` | `check-w0-bytes-io.sh` | **G-net**, **G-stdlib** |
| 3 | `w1-async-reactor` | `check-w1-async-reactor.sh` | **G-async** |
| 4 | `h-lean-server-modules` | `check-httpd-server-lean-gate.sh` | **G-lean** (server modules) |
| 5 | `m0-ship-gate-full` | `build-li-httpd.sh` + `test-auth-bearer.sh` | compile certificate |
| 6 | `m1-exploit-runtime` | `check-tier5-exploit-runtime.sh` | trusted seam evidence |
| 7 | `m1-serve-production` | `test-serve-production.sh` | **G-net**, **G-async** runtime |
| 8 | Config/oracle suite | `run_httpd_config.sh`, overlap/validate scripts | **G-vc** (routing proofs) |

**Phase H M1 `.li` tracker closes** when steps 1–8 pass + Doc-c cross-links updated — **T5** in [#30](https://github.com/li-langverse/lic/issues/30) exit graph.

---

## Sub-phases (after `plan-approved`)

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Merge this plan + li-httpd plan section | Plan PR + #18 comment |
| **B** | Post exit-matrix pass/fail on #18 from one `httpd-plan-gates.sh` run | Issue comment with script tail |
| **C** | Implementation agents use checklist; no tracker Done until T5 gates green | `httpd-plan-gates.sh` without skips |
| **D** | Sync [#30](https://github.com/li-langverse/lic/issues/30) exit-graph sub-phases D–F if not yet merged | Doc PR cross-links |

---

## Tests / verification

| Check | Command | Tier |
|-------|---------|------|
| Httpd P0 lean slice | `./scripts/check-httpd-lean-gate.sh` | T2 |
| Server module Lean | `./scripts/check-httpd-server-lean-gate.sh` | T5 |
| Bytes / async P0 | `./scripts/check-w0-bytes-io.sh`, `./scripts/check-w1-async-reactor.sh` | T1 |
| Full httpd plan gates | `./scripts/httpd-plan-gates.sh` | T3–T4 |
| Doc claim guard | `./scripts/check-doc-provability-claims.sh` | Doc-c |

---

## Related issues

| Issue | Relationship |
|-------|--------------|
| [#18](https://github.com/li-langverse/lic/issues/18) | **This plan** — P0 checklist + M1 gate order |
| [#30](https://github.com/li-langverse/lic/issues/30) | Exit graph / T-tier definitions ([PR #1088](https://github.com/li-langverse/lic/pull/1088)) |
| [#32](https://github.com/li-langverse/lic/issues/32) | **T6** — global **G-lean** / **G-vc** evidence |

---

## Human-only

- [ ] Label **`plan-approved`** on #18 before implementation track (sub-phase C).
- [ ] Remove **`plan-needed`** when plan PR merges.
- [ ] Acknowledge any increase to `HTTPD_LEAN_GATE_MAX_OPEN` via explicit issue.
