# PH-DB-13 — Cloud Studio & Projects

**Status:** Phase 1 in progress (2026-05-31)  
**Repo:** `lis/data-studio-ui`  
**Supersedes agent UX:** PH-DB-12 agents trace / control-plane tables removed from studio UI

---

## 1. Executive summary

Li Data Studio pivots from a single local `lis db` console with agent control-plane visibility to a **Supabase-like cloud studio**: sign in (stub), org → project hierarchy, per-project database containers, and polished Database / SQL / Settings tabs scoped to the selected project.

Agent orchestration remains in `li-cursor-agents`; it is **not** surfaced in Data Studio.

---

## 2. User stories

| ID | Story | Acceptance |
|----|-------|------------|
| U1 | As a developer I can **sign up / sign in** | Stub sign-in button (C1); real OAuth later |
| U2 | As a user I can **create an org** | Default org `default` in phase 1; multi-org in C1 |
| U3 | As a user I can **create a project** (name, region) | POST `/api/projects`; card on landing |
| U4 | As a user I can **provision a DB container** for a project | Launch database → `lis db start` with project `LI_DATA_DIR` + ports (C3: docker compose per project) |
| U5 | As a user I can **open studio tabs** for my project | Database, SQL Editor, Settings under `/projects/:id/*` |
| U6 | As a user I see **Supabase-quality UX** | Dark sidebar, green accent, tight cards, no agent nav (C5) |

---

## 3. Architecture

### 3.1 Project registry

Phase 1: JSON file at `$STUDIO_DATA_DIR/projects.json`:

```json
{
  "version": 1,
  "nextPortOffset": 0,
  "projects": [{
    "id": "uuid",
    "orgId": "default",
    "name": "My app",
    "region": "us-east-1",
    "dataDir": "~/.local/share/lis/studio/projects/{id}/data",
    "ports": { "api": 55000, "db": 55001, "realtime": 55002 },
    "status": "stopped",
    "createdAt": "…",
    "updatedAt": "…"
  }]
}
```

Future (C2+): migrate to `lidb.studio_projects` table for multi-tenant cloud hosting.

### 3.2 Container / process model

| Layer | Phase 1 | Phase C3 |
|-------|---------|----------|
| Provision | `lis db start` via Next.js API with per-project env | `docker compose -f docker-compose.ph-db.yml` per project + volume |
| Data | `LI_DATA_DIR` per project | Named volume `li-data-{projectId}` |
| Ports | Sequential allocation from 55000 | Same; document collision avoidance |
| Health | `lis db status` with project env | Compose healthcheck |

**Windows / WSL limits:** Native `lis db` on Windows requires `LIS_DB_STATUS_SHELL=bash` (Git Bash/WSL). Docker path preferred on Windows once C3 lands.

### 3.3 Studio routing

```
/                     → Projects landing (org shell)
/projects/new         → Create project form
/projects/:id         → Project dashboard + Launch database
/projects/:id/database
/projects/:id/sql
/projects/:id/settings
```

Legacy `/database`, `/agents`, etc. redirect or removed.

### 3.4 API surface (phase 1)

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/projects` | GET, POST | List / create |
| `/api/projects/:id` | GET | Project detail + health |
| `/api/projects/:id/launch` | POST | Start `lis db` |
| `/api/projects/:id/db/*` | * | Project-scoped bridge (status, tables, query) |
| `/api/projects/:id/settings` | GET | Project env summary |

---

## 4. UX direction

Reference: Supabase Dashboard / Studio (dark theme, left nav, project context header, card grid on home).

| Element | Direction |
|---------|-----------|
| Sidebar | 240px, `#232323` surface, green `#3ecf8e` active indicator |
| Landing | Project cards with region + port hint |
| Project home | Status cards → Database / SQL / Settings; primary **Launch database** CTA |
| Typography | System UI stack; tighter h1 (1.5rem), uppercase micro-labels on cards |
| **Excluded** | Agents tab, control-plane tables, agent run lists |

---

## 5. Work packages

| WP | ID | Scope | Exit gate |
|----|-----|-------|-----------|
| **C1** | Auth stub | Sign in/up UI, session cookie stub, org selector | Button + `/api/auth/session` mock |
| **C2** | Project CRUD | JSON store → optional lidb table; edit/delete project | CRUD API + UI |
| **C3** | Container provisioner | Docker compose per project; stop/restart | `launch` uses compose on Linux/macOS |
| **C4** | Project-scoped studio | All DB/SQL paths via project env (phase 1 done) | No global `LI_DATA_DIR` leakage |
| **C5** | Polish | Command palette in project shell, loading skeletons, table editor UX | Visual parity pass vs Supabase screenshots |

**Phase 1 delivered (lis PR):** C2 partial, C4, agent removal, C5 partial.

---

## 6. Honest gaps

- **No real auth** — sign-in is disabled stub; no OAuth, no multi-tenant isolation
- **No cloud hosting** — local JSON store + local `lis db start` only
- **No docker-per-project yet** — C3; Windows relies on bash/WSL for CLI
- **No write path** — SQL remains read-only SELECT
- **Single default org** — org CRUD deferred to C1

---

## 7. Related docs

- [ph-db-11-li-data-studio.md](ph-db-11-li-data-studio.md) — original studio epic
- [ph-db-ci-hosting-plan.md](ph-db-ci-hosting-plan.md) — container CI
- `lis/data-studio-ui/README.md` — operator quick start
