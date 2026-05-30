# Live handbook sites (GitHub Pages)

Org preflight (`ecosystem-audit.json`) tracks repos that should expose a **handbook landing** at `https://li-langverse.github.io/<repo>/`. Rows are **not** proof certificates — see [provability gaps](../verification/provability-gaps.md).

## Canonical language handbook

| Repo | Pages URL | Notes |
|------|-----------|--------|
| **`li-language`** | https://li-langverse.github.io/li-language/ | MkDocs Material site (`mkdocs.yml`); primary reader path for compiler docs |
| **`lic`** | (same as `li-language`) | Compiler source of truth; handbook deploys from **`li-language`** until migration completes |

Do not expect `https://li-langverse.github.io/lic/` — that path 404s by design today.

## Satellite handbooks (static `site/index.html`)

These repos ship `.github/workflows/pages.yml` and a checked-in `site/index.html` that links back to the master plan, provability gaps, and benchmarks dashboard.

| Repo | Expected URL | In-repo handbook |
|------|--------------|------------------|
| **lip** | https://li-langverse.github.io/lip/ | [`docs/handbook.md`](https://github.com/li-langverse/lip/blob/main/docs/handbook.md) |
| **lit** | https://li-langverse.github.io/lit/ | (with lip) |
| **lis** | https://li-langverse.github.io/lis/ | [`docs/`](https://github.com/li-langverse/lis/tree/main/docs) |
| **roadmap** | https://li-langverse.github.io/roadmap/ | [`docs/`](https://github.com/li-langverse/roadmap/tree/main/docs) |
| **li-demo** | https://li-langverse.github.io/li-demo/ | [`docs/handbook.md`](https://github.com/li-langverse/li-demo/blob/main/docs/handbook.md) |
| **li-net** | https://li-langverse.github.io/li-net/ | [`docs/handbook.md`](https://github.com/li-langverse/li-net/blob/main/docs/handbook.md) |
| **li-httpd** | https://li-langverse.github.io/li-httpd/ | [`docs/handbook.md`](https://github.com/li-langverse/li-httpd/blob/main/docs/handbook.md) |
| **li-std-core** | https://li-langverse.github.io/li-std-core/ | [`docs/handbook.md`](https://github.com/li-langverse/li-std-core/blob/main/docs/handbook.md) |
| **li-std-math** | https://li-langverse.github.io/li-std-math/ | [`docs/handbook.md`](https://github.com/li-langverse/li-std-math/blob/main/docs/handbook.md) |

## Org dashboards

| Repo | URL |
|------|-----|
| **benchmarks** | https://li-langverse.github.io/benchmarks/ |

## Enable or fix Pages (maintainer)

1. **Settings → Pages → Build and deployment → GitHub Actions** on the repo (org admin if the repo is new).
2. Merge to **`main`** so `pages.yml` runs (workflow skips PR builds).
3. Verify: `curl -sI -o /dev/null -w '%{http_code}\n' https://li-langverse.github.io/<repo>/` → `200` or `301` to `200`.
4. Update **`benchmarks/scripts/ecosystem-audit.py`** `LIVE_DOCS` when a URL is stable (HEAD probe).

**Stale mkdocs deploy (`li-language`):** if live nav tabs lag `mkdocs.yml`, fix strict build + redeploy — see [lic#403](https://github.com/li-langverse/lic/issues/403).

## Cross-links

- [Plan cross-links](plan-cross-links.md) — master plan ↔ provability-gaps ↔ phase plans
- [Agent coordination](agent-coordination.md)
- [Benchmarks SETUP_GITHUB](https://github.com/li-langverse/benchmarks/blob/main/SETUP_GITHUB.md) — dashboard 404 recovery
