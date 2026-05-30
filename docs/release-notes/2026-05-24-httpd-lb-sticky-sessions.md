# HTTPd — upstream sticky sessions (ip_hash + cookie)

## Summary

Completes plan todo **gap-lb-sticky-sessions**: `[upstreams.*].balance` supports `ip_hash` and `cookie` (plus existing `round_robin` / `least_conn`), with runtime peer selection and `test-lb-sticky-sessions.sh` on `build/li-httpd`.

## User-visible

| Mode | Behavior |
|------|----------|
| `ip_hash` | Client IPv4 (TCP peer) maps to a fixed peer in the pool; failover scans peers if the hash target is down. |
| `cookie` | Gateway sets `Set-Cookie: li_route=<peer_port>` on proxy responses; later requests with that cookie route to the same peer (port must be in the validated pool). |

## Changed

| Area | Paths |
|------|--------|
| Runtime | `runtime/li_rt_net.c` — client IP on accept, LB modes 2/3, `li_route` cookie inject on proxy headers |
| Config | `scripts/flatten-httpd-config.py`, `scripts/validate-httpd-config.py` |
| Examples | `packages/li-net-httpd/examples/sticky_sessions.toml`, `sticky_sessions_cookie.toml` |
| Gates | `scripts/test-lb-sticky-sessions.sh`, `scripts/httpd-plan-gates.sh` |
| Li surface | `packages/li-http/src/lib.li`, `li-tests/httpd/lb_mode_smoke.li` |
| Reject fixture | `li-tests/config_desugar/reject/lb_bad_balance.toml` |
| Plan | `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` |

## Security

- Clients cannot pick arbitrary backends: `li_route` values are accepted only when they match a configured upstream peer port.
- Ingress allowlist unchanged (no `X-Backend`); affinity is config enum + server-issued cookie only.

## Test

```bash
./scripts/build-li-httpd.sh
./scripts/test-lb-sticky-sessions.sh
./scripts/httpd-plan-gates.sh
```
