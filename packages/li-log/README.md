# li-log (M1 stub)

Structured access, audit, and error logging for **li-httpd** and agent gateways.

## Status

Package scaffold only — **M1 wave 5**. li-httpd still emits minimal stderr lines from the C runtime; this package defines the contract for:

- RFC3339 timestamps
- Rotation hooks (`max_size`, `max_files`)
- Redact-by-default for `Authorization`, cookies, API keys

## Next

1. `src/lib.li` — `log_access`, `log_error`, `log_audit` seams
2. Wire `packages/li-net-httpd` to import `log` after `lic build` includes package path
3. Tier5 scenario `access_log_format` when JSON lines land

See [li-httpd plan](../li-httpd/../../docs/superpowers/plans/2026-05-16-li-httpd-plan.md) (`li-log-package` todo).
