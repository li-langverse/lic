# li-httpd M1 baseline (2026-05-22)

**Purpose:** Clean record after landing proxy/runtime fixes on `main`, before autonomous plan loop continues.

**Plan:** [2026-05-16-li-httpd-plan.md](../superpowers/plans/2026-05-16-li-httpd-plan.md) · **Master plan:** Phase H in [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md)

## On `main` today (do not re-merge)

| PR | What |
|----|------|
| #153 | Proxy EPOLLOUT, seam ABI, ptr codegen |
| #156 | E0360 extern pointer-width ABI guard |
| #157 | Static recv without index cache; config proxy epoll |
| #158 | `packages/li-log`, access sink, redaction tests |

**Runtime:** `runtime/li_rt_net.c`, `runtime/li_rt_httpd.c`, `runtime/li_rt_log.c`  
**Packages:** `packages/li-net-httpd`, `packages/li-http`, `packages/li-log`  
**Scripts:** `httpd_config.py`, overlap/validate/flatten tooling (see open PR #160)

## Stale PRs — close, do not merge wholesale

| PR | Reason |
|----|--------|
| #87, #84, #130, #119 | Parallel history; C/proxy paths superseded by #153–#158 |
| #149 | Docs-only; fold into baseline or close |

## Open integration (target one PR)

| Branch / PR | Content |
|-------------|---------|
| `cursor/httpd-plan-continue-54aa` (#160) | Overlap reject, validate/flatten, Bearer auth |
| Plan loop | `scripts/httpd-plan-loop.py` + `code_implementer` (`--goal-file`) — PR #172 |
| Implementation | `cursor/httpd-plan-loop-54aa` → PR #173 |

## Next todos (plan loop order)

1. ~~**m1-routing-tests**~~ — done (`run_routing.sh`, table cases, overlap `config_reject`)  
2. ~~**m1-bearer-auth**~~ — `test-auth-bearer.sh` on real `build/li-httpd` (done; use `./scripts/build-li-httpd.sh`)  
3. ~~**m1-toml-desugar**~~ — desugar golden + explain-config (`check-httpd-config-desugar.sh`)  
4. **m1-core** (in progress) — global `limits.rate_limit_rps` required for `proxy:` routes (Python validator + examples); remaining LB/parser Li surface  
5. **w1-async-reactor** — blocked on language async (post-M1)

## Autonomous loop

```bash
export CURSOR_API_KEY=cursor_...
export LI_CURSOR_AGENTS_ROOT=/path/to/li-cursor-agents
cd lic
./scripts/httpd-plan-loop.py --once    # one SDK iteration
./scripts/httpd-plan-loop.py --max 20 # overnight-style
```

Preflight (optional): `cd ../benchmarks && ./scripts/agent-preflight.sh`

## Agent continuation

1. Read this file + plan YAML todos.  
2. Run `./scripts/httpd-plan-gates.sh`.  
3. `./scripts/httpd-plan-loop.py --once` (or implement todo manually).  
4. Push PR; human merges after CI + review.  
5. **Blocked:** full `li-net-httpd` Li build without `import std.runtime.seam` (E0202 proxy externs).
