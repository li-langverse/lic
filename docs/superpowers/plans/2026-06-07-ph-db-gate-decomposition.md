# PH-DB gate decomposition — phased issues + owner map

**Status:** Plan (2026-06-07) · **Issue:** [lic#423](https://github.com/li-langverse/lic/issues/423)  
**Supersedes:** ad-hoc checkbox debt in [ph-db-battle-plan.md](ph-db-battle-plan.md) and [ph-db-execution-tracker.md](ph-db-execution-tracker.md) as the **canonical gate registry**  
**Related:** [ph-db-lidb-platform.md](ph-db-lidb-platform.md) · [2026-06-03-ph-db-plan-loop.md](2026-06-03-ph-db-plan-loop.md) (lic#576, PR #765) · [ph-db-swarm-plan.md](ph-db-swarm-plan.md)

---

## 1. Executive summary

Plan-completion audit (**2026-05-29**) reported **40 open gates** in `ph-db-battle-plan.md`. Re-count on **2026-06-07** (`main`): **36** battle-plan task checkboxes + **44** execution-tracker DoD/phase gates = **80** open checkboxes across PH-DB sub-plans (~30 overlap semantically with WP tasks in §5). Sub-plan debt is real; swarm canvas todos (#576) do **not** replace per-gate closure.

**North star fit:** **G-proof-db** (Partial) — proof-first embed path (`lidb` + `liq` + `lis db`); honest `tier_db_*` rows; no fake registry-min done.

**Pillar order:** proof → easy → fast. Embed path must wire `liorm.execute` to native engine **before** claiming PH-DB-5 bench exit or default `LI_CONTROL_PLANE_STORE=lidb`.

**This plan delivers (plan-only):**

1. Stable **PH-DB-* gate IDs** for every open checkbox  
2. **Owner repo** per gate (`lidb` / `lis` / `benchmarks` / `li-cursor-agents` / `lip` / `lic` / `research-findings`)  
3. **Seven phased implementation issues** (file in owner repo when `plan-approved`)  
4. **Master plan PH-DB tracker row** with gate debt + link here  
5. **Closure policy:** checkboxes close only in PRs that cite test/CI command + link

**Not in scope:** product code, default store flip, self-merge, new Actions `schedule:` cron.

---

## 2. Learned from

| Reference | Adopt for PH-DB |
|-----------|-----------------|
| [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html) | Multi-tenant registry policies (`002_rls_registry.sql`); fail-closed probes |
| [SQLite embedded OLTP](https://www.sqlite.org/whentouse.html) | In-process embed for registry-min; single-engine handoff to `lis` |
| [Supabase migrations + RLS](https://supabase.com/docs/guides/database/postgres/row-level-security) | Control-plane schema parity (DB-R0-4); no raw agent SQL |
| [Cargo workspace CI](https://doc.rust-lang.org/cargo/reference/workspaces.html) | Cross-repo PR signal pattern for WP-G (engine e2e + smoke matrix) |

---

## 3. Closure policy (mandatory)

A gate checkbox (`- [ ]`) in any PH-DB plan file may flip to `- [x]` **only** when the closing PR includes:

| Field | Required |
|-------|----------|
| **Gate ID** | e.g. `PH-DB-2-A03` in PR body or commit message |
| **Test command** | Exact shell command run locally or in CI |
| **CI evidence** | Link to green workflow run **or** pasted exit code + log excerpt |
| **Owner repo** | PR merged in the gate's owner repo (docs-only gates may land in `lic`) |

**Forbidden:** closing gates by doc edit alone; marking `tier_db_*` green without measured P95; claiming PH-DB-4 done without `registry_smoke` green.

Audit ingest: `benchmarks/scripts/plan-completion-audit.py` reads open `- [ ]` from linked plan paths — re-run after each gate batch merges.

---

## 4. Phased issue split (implementation queue)

File **one issue per row** in the **owner repo** after this plan merges and receives `plan-approved`. Link back to lic#423 and the gate IDs below.

| Phase ID | Proposed issue title | Owner repo | WP | Open gates | Blocked by | REQ / bench |
|----------|---------------------|------------|-----|------------|------------|-------------|
| **PH-DB-2** | `[PH-DB-2] lidb embed engine — pytest green, liorm wire, security harness` | `lidb` | A | A01–A06, TRK-A×4 | Wave 0 merges | `bash scripts/smoke.sh && bash scripts/run_tests.sh`; security `run_all.sh` |
| **PH-DB-3** | `[PH-DB-3] lis db supervisor — registry-min profile + CI pytest` | `lis` | B | B01–B06, TRK-B×3 | soft PH-DB-2 | `bash scripts/db-smoke.sh`; formal pytest in CI |
| **PH-DB-5** | `[PH-DB-5] tier_db_registry — lidb vs Postgres P95 harness` | `benchmarks` | C | C01–C06, TRK-C×2, TRK-P3×1 | PH-DB-2; Postgres CI | `BENCH_DB_REGISTRY_RUN_HARNESS=1`; ratio ≤ 1.2 |
| **PH-DB-4** | `[PH-DB-4] Registry v2 central DB — schema, lip OpenAPI, RLS design` | `lidb` (+ `lip`) | D | D01–D06, TRK-D×5 | PH-DB-2, PH-DB-3 | `registry_smoke.sh`; pytest green; human PH-8d-v2 sign-off |
| **PH-DB-10** | `[PH-DB-10] Control-plane lidb persist — liorm, liq MCP, e2e` | `li-cursor-agents` | E | E01–E07, TRK-E×3 | PH-DB-2, PH-DB-3 | `npm test`; `LI_E2E_LIDB=1 npm run test:e2e:lidb` |
| **PH-DB-G0** | `[PH-DB-G0] DB-R0 research — study-only ADR inputs` | `research-findings` | F | F01–F05, TRK-F×1 | — | `scripts/reproduce.sh` exit 0; `validity_grade: study-only` |
| **PH-DB-W3** | `[PH-DB-W3] Wave 3 CI/containers — WP-G…K cross-repo gates` | multi (`li-cursor-agents`, `lis`, `benchmarks`, `lidb`) | G–K | TRK-G…K×16, TRK-P0…P3×7 | PH-DB-2, PH-DB-10, PH-DB-5 prep | `ph-db-plan-gates.sh`; compose smoke; nightly Postgres |

**lic tracking issue:** [lic#423](https://github.com/li-langverse/lic/issues/423) closes when all gate IDs below are `- [x]` or explicitly deferred with human sign-off (`wp-prod-lidb-default`).

**Duplicate check:** Not a duplicate of lic#576 (plan-loop YAML — closed) or lic#765 (orchestration wiring — open). This plan owns **gate-level** decomposition; #576 owns **runner todos**.

---

## 5. Gate registry — battle plan (36 gates)

Source: [ph-db-battle-plan.md](ph-db-battle-plan.md) on `main` (2026-06-07).

### PH-DB-2 / WP-A — `lidb` engine (6 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-2-A01 | `lidb` | `bash scripts/run_tests.sh` — 0 pytest failures on `main`; release note cites root cause |
| PH-DB-2-A02 | `lidb` | `liorm/embed_engine.py` — `lidb_embed` only; `grep -r sqlite3 liorm/` empty in CI |
| PH-DB-2-A03 | `lidb` | Integration test: `liorm.execute` registry-min plan vs live catalog |
| PH-DB-2-A04 | `lidb` | `bash tests/security/run_all.sh` — injection + RawSqlCapability fail closed |
| PH-DB-2-A05 | `lidb` | PR CI: `check_no_sqlite.sh`, smoke, pytest, security on every PR |
| PH-DB-2-A06 | `lidb` | `docs/pg-subset-v1.md` status table matches implemented surface |

### PH-DB-3 / WP-B — `lis` db supervisor (6 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-3-B01 | `lis` | `lis db start\|migrate\|status\|stop` per handoff |
| PH-DB-3-B02 | `lis` | `profiles/registry-min.toml` committed + loaded on start |
| PH-DB-3-B03 | `lis` | In-process embed — no loopback TCP for registry-min profile |
| PH-DB-3-B04 | `lis` | `lis db status` JSON — `assertStoreReady()` contract test in agents |
| PH-DB-3-B05 | `lis` | README env contract + cross-link `lidb/docs/handoff-wp5-lis.md` |
| PH-DB-3-B06 | `lis` | `bash scripts/db-smoke.sh` on clean `LI_DATA_DIR` |

### PH-DB-5 / WP-C — `benchmarks` tier_db_registry (6 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-5-C01 | `benchmarks` | `registry_oltp_stub.py` → real lidb embed + Postgres 15+ driver |
| PH-DB-5-C02 | `benchmarks`, `lidb` | DDL diff: `schema/registry-v1.sql` ↔ `lidb/migrations/001_registry.sql` = 0 blocking |
| PH-DB-5-C03 | `benchmarks` | Scenarios `registry_publish`, `registry_read_by_name`, `registry_read_latest` emit timings |
| PH-DB-5-C04 | `benchmarks` | `results/latest.csv` + ingest JSON; `status` from data not stub |
| PH-DB-5-C05 | `benchmarks` | `BENCH_DB_REGISTRY_THRESHOLD=1.2` documented in tier README |
| PH-DB-5-C06 | `benchmarks` | CI: Postgres-only path + optional nightly full compare |

### PH-DB-4 / WP-D — registry central DB (6 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-4-D01 | `lidb`, `roadmap` | DB-R0-1 gap table: `registry-v1.sql` vs lip OpenAPI |
| PH-DB-4-D02 | `lidb` | v2 migration merged; `001_registry.sql` parity preserved |
| PH-DB-4-D03 | `lip` | OpenAPI field map to lidb catalog — no fake 8d v2 ship |
| PH-DB-4-D04 | `lidb` | `002_rls_registry.sql` design review recorded (ADR or plan §) |
| PH-DB-4-D05 | `lic` | Traceability cross-link in `ph-db-lidb-platform.md` when checklist exists |
| PH-DB-4-D06 | `lip` | PRs labeled `blocked-on-PH-DB-4` until schema merged |

### PH-DB-10 / WP-E — control plane (7 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-10-E01 | `li-cursor-agents`, `lidb` | DB-R0-4 schema parity table vs Supabase migrations |
| PH-DB-10-E02 | `li-cursor-agents` | `persistControlPlaneStateLidb` via liorm — no no-op stub |
| PH-DB-10-E03 | `li-cursor-agents` | `runLiqQuery` → real liorm when `LI_LIDB_URL` or `LI_DATA_DIR` |
| PH-DB-10-E04 | `li-cursor-agents` | `lidb-control-plane.e2e.ts` — zero `test.todo` for persist gates |
| PH-DB-10-E05 | `li-cursor-agents` | `scripts/backfill-control-plane-db.mjs` lidb import path |
| PH-DB-10-E06 | `li-cursor-agents` | Optional CI job `LI_E2E_LIDB=1` (non-blocking until stable) |
| PH-DB-10-E07 | `li-cursor-agents` | `.cursor/skills/explore-control-plane-db/SKILL.md` updated for liq MCP |

### PH-DB-G0 / WP-F — research (5 gates)

| Gate ID | Owner | Close command / evidence |
|---------|-------|--------------------------|
| PH-DB-G0-F01 | `research-findings` | DB-R0-1 boundary table artifact |
| PH-DB-G0-F02 | `research-findings` | DB-R0-4 control-plane gap + liq threat notes |
| PH-DB-G0-F03 | `research-findings` | DB-R0-5 agent read-path threat model |
| PH-DB-G0-F04 | `research-findings` | DB-R0-2 / DB-R0-6 surveys (study-only) |
| PH-DB-G0-F05 | `benchmarks` | `tier_db_*` dashboard rows stay **unknown** until PH-DB-5-C03 |

---

## 6. Gate registry — execution tracker (44 gates)

Source: [ph-db-execution-tracker.md](ph-db-execution-tracker.md) §2 DoD columns + §4 phase exit list. Maps to §5 battle gates where noted.

| Gate ID | WP | Owner | Summary | §5 xref |
|---------|-----|-------|---------|---------|
| PH-DB-TRK-A01 | A | `lidb` | smoke + pytest green on `main` | A01, A05 |
| PH-DB-TRK-A02 | A | `lidb` | security harness: zero critical skips/fails | A04 |
| PH-DB-TRK-A03 | A | `lidb` | `liorm.execute` vs native embed integration test | A03 |
| PH-DB-TRK-A04 | A | `lidb` | WP-A PR merged | — |
| PH-DB-TRK-B01 | B | `lis` | formal pytest in CI | — |
| PH-DB-TRK-B02 | B | `lis` | README env contract sign-off | B05 |
| PH-DB-TRK-B03 | B | `lis` | WP-B PR merged | — |
| PH-DB-TRK-C01 | C | `benchmarks` | Postgres P95 + ratio ≤ 1.2 (3 scenarios) | C03, C06 |
| PH-DB-TRK-C02 | C | `benchmarks` | WP-C PR merged | — |
| PH-DB-TRK-D01 | D | `lidb` | `registry_smoke` green | — |
| PH-DB-TRK-D02 | D | `lidb` | pytest green on branch | — |
| PH-DB-TRK-D03 | D | `lip` | OpenAPI parity — zero blocking v2 read fields | D03 |
| PH-DB-TRK-D04 | D | human | PH-8d-v2 unblock sign-off | — |
| PH-DB-TRK-D05 | D | `lidb`, `lic` | WP-D PRs merged | — |
| PH-DB-TRK-E01 | E | `li-cursor-agents` | engine e2e: clear handoffs + control_plane_reports todos | E04 |
| PH-DB-TRK-E02 | E | `li-cursor-agents` | persist via liorm without `LI_LIDB_MOCK=1` | E02 |
| PH-DB-TRK-E03 | E | `li-cursor-agents` | WP-E PR merged | — |
| PH-DB-TRK-F01 | F | `research-findings` | WP-F PR merged | — |
| PH-DB-TRK-G01 | G | `li-cursor-agents` | agents PR CI re-enabled | — |
| PH-DB-TRK-G02 | G | `li-cursor-agents` | job `lidb-engine-e2e` with lidb checkout + cmake | — |
| PH-DB-TRK-G03 | G | `li-cursor-agents` | mock e2e on every agents PR | — |
| PH-DB-TRK-G04 | G | `li-cursor-agents` | WP-G PR merged | — |
| PH-DB-TRK-H01 | H | `lidb` | `lidb/docker/Dockerfile.embed` | — |
| PH-DB-TRK-H02 | H | `lis` | `lis/docker/Dockerfile.supervisor` | — |
| PH-DB-TRK-H03 | H | `lis` | `docker-compose.ph-db.yml` healthcheck | — |
| PH-DB-TRK-H04 | H | `lis` | WP-H PR merged | — |
| PH-DB-TRK-I01 | I | `lis` | merge WP-B; formal pytest in CI | TRK-B01 |
| PH-DB-TRK-I02 | I | `lis` | `lis db start --foreground`; systemd sample | — |
| PH-DB-TRK-I03 | I | `lis` | db-smoke mandatory ubuntu + macOS | B06 |
| PH-DB-TRK-I04 | I | `lis` | WP-I PR merged | — |
| PH-DB-TRK-J01 | J | `lidb` | JSON schema: `lis db status`, bridge stdout | — |
| PH-DB-TRK-J02 | J | `lidb` | bridge session reuse; protocol semver doc | — |
| PH-DB-TRK-J03 | J | `lidb` | WP-J PR merged | — |
| PH-DB-TRK-K01 | K | `benchmarks` | GHA `services: postgres:16` nightly + dispatch | C06 |
| PH-DB-TRK-K02 | K | `benchmarks` | `BENCH_DB_REGISTRY_RUN_HARNESS=1` compare profile | C01 |
| PH-DB-TRK-K03 | K | `benchmarks` | artifact: numeric P95 + ratio or explicit `failed` | C04 |
| PH-DB-TRK-K04 | K | `benchmarks` | WP-K PR merged | — |
| PH-DB-TRK-P01 | Phase 0 | multi | WP-G CI foundation exit | TRK-G01–G04 |
| PH-DB-TRK-P02 | Phase 1 | multi | WP-H containers exit | TRK-H01–H04 |
| PH-DB-TRK-P03 | Phase 2 | multi | WP-I hosting exit | TRK-I01–I04 |
| PH-DB-TRK-P04 | Phase 3 | multi | WP-J + WP-K prod gates | TRK-J*, TRK-K* |
| PH-DB-TRK-P05 | cross | `lidb`, agents | WP-A security + WP-E e2e todos cleared | TRK-A02, TRK-E01 |
| PH-DB-TRK-P06 | cross | `benchmarks` | PH-DB-5 measured P95 ≤ 1.2× Postgres | TRK-C01 |
| PH-DB-TRK-P07 | human | — | production `LI_CONTROL_PLANE_STORE=lidb` flip | — |

---

## 7. Master plan tracker row (PH-DB)

Add to [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) phase table and v2 backlog:

| Field | Value |
|-------|-------|
| **ID** | **PH-DB** |
| **Gap** | **G-proof-db** (Partial) |
| **Open gates** | **80** checkboxes (36 battle + 44 tracker; 2026-06-07) — [gate registry §5–6](2026-06-07-ph-db-gate-decomposition.md) |
| **Phase index** | [ph-db-lidb-platform.md](ph-db-lidb-platform.md) PH-DB-0…10 |
| **Execution** | [ph-db-battle-plan.md](ph-db-battle-plan.md) WP-A…F · [ph-db-execution-tracker.md](ph-db-execution-tracker.md) WP-G…K |
| **Orchestration** | [2026-06-03-ph-db-plan-loop.md](2026-06-03-ph-db-plan-loop.md) (lic#576) |
| **Blocks** | **PH-8d-v2** until **PH-DB-4** exit |
| **Honesty rule** | `tier_db_*` = measured or unknown — never stub-green |

---

## 8. REQ / bench / test map

| REQ / bench | Gate IDs | Owner |
|-------------|----------|-------|
| REQ-DB-EMBED-1 native-only embed | A02, B03, TRK-A03 | `lidb`, `lis` |
| REQ-DB-SEC-1 liq fail-closed | A04, A05, G0-F03 | `lidb` |
| REQ-DB-REG-1 registry-min plans | A03, B01–B02 | `lidb`, `lis` |
| **tier_db_registry** P95 ratio | C01–C06, TRK-C01, TRK-P06 | `benchmarks` |
| **tier_db_security** (WP-N5) | A04, G0-F03 | `lidb`, `benchmarks` |
| REQ-CP-1 control-plane persist | E01–E04, TRK-E01–E02 | `li-cursor-agents` |
| REQ-REG-V2-1 central DB | D01–D06, TRK-D01–D05 | `lidb`, `lip` |

---

## 9. Anti-goals (unchanged from battle plan)

- No stub-green bench rows  
- No PH-8d-v2 before PH-DB-4  
- No default `LI_CONTROL_PLANE_STORE=lidb` without TRK-P05 + TRK-P06 + human TRK-P07  
- No sqlite3 reintroduction on embed path  
- No gate closure without test/CI cite (§3)

---

## 10. References

| Doc | Path |
|-----|------|
| Vision | [roadmap/vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| Engineering standards | [roadmap/engineering-standards.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md) |
| Control plane migration | [li-cursor-agents/lidb-migration-control-plane.md](https://github.com/li-langverse/li-cursor-agents/blob/main/docs/plans/lidb-migration-control-plane.md) |
| Plan audit source | `benchmarks/data/latest/plan-completion-audit.json` |
| Issue | [lic#423](https://github.com/li-langverse/lic/issues/423) |
