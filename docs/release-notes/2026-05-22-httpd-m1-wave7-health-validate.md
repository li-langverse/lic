# li-httpd M1 wave 7 — passive health + lic validate-httpd-config

## Summary

Upstream peers auto-mark down after connect failures (`health_max_fails` / `health_fail_timeout_sec`); config validation wrapper runs route desugar + overlap checks on every example TOML.

## Agent continuation

1. **Read** `packages/li-httpd/examples/passive_health.toml`; `runtime/li_rt_net.c` `httpd_upstream_peer_note_failure`.
2. **Run** `./scripts/lic-validate-httpd-config.sh examples/*.toml`; `./scripts/test-passive-upstream-health.sh`; rebuild `build/li-httpd`.
3. **Then** M1.5 `li-tls` scaffold; active health probes; compiler `lic validate-httpd-config` subcommand.
4. **Blocked on** PH-2e Lean VC for proof-backed health state machine.

## Changed

- `runtime/li_rt_net.c` — passive health buckets, peer recovery, LB skip dead peers.
- `scripts/flatten-httpd-config.py` — `[health]` table → runtime keys.
- `scripts/validate-httpd-config.py` — `load_httpd_config` overlap gate.
- `scripts/lic-validate-httpd-config.sh`, `scripts/test-passive-upstream-health.sh`, `scripts/ci.sh`.

## Not changed

- TLS / SSE / HTTP/2.
- Active health `GET /ready` probes (M1.5).
- Tier5 harness (existing `lb_peer_down` still uses manual kill).

## Breaking

N/A — defaults `max_fails=1`, `fail_timeout=10s` when `[health]` omitted.

## Security

Dead peers stop receiving traffic after bounded failures (limits blind failover to blackholes).

## Performance

N/A — failover retry loop unchanged except skip `down` peers faster.

## Downstream

- **benchmarks:** `./scripts/httpd-masterplan-step.sh step-7-...` after merge.
