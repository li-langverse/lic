# Release notes: nginx-src-audit (tier5_http)

**Branch:** `cursor/httpd-plan-continue`

## Summary

Read-only nginx security oracle: submodule pin `release-1.26.2`, `nginx_mitigations.toml` checklist (no `li_done`), `audit_nginx_src.py` + CI gate. CHANGES fixture for GitHub-mirror clones without root `CHANGES`.

## Changed

- `benchmarks/tier5_http/third_party/nginx` (submodule), `fixtures/nginx-1.26.2-CHANGES.txt`
- `benchmarks/tier5_http/nginx_mitigations.toml`, `third_party/README.md`
- `benchmarks/harness/audit_nginx_src.py`
- `scripts/check-tier5-nginx-src-audit.sh`, `scripts/httpd-plan-gates.sh`
- `docs/security-nginx-src-audit.md`, plan todo `nginx-src-audit` → `completed`

## Test commands

```bash
./scripts/check-tier5-nginx-src-audit.sh
HTTPD_GATES_SKIP_LIC_BUILD=1 ./scripts/httpd-plan-gates.sh
```

## Not changed

- Live Pages bench refresh (`SKIP_BENCH=1`)
- Full Tier B–F exploit corpus stubs
- Li runtime / proof obligations (checklist only)

## Breaking / Security / Performance / Downstream

| Area | Note |
|------|------|
| Breaking | N/A — audit tooling |
| Security | Curated nginx mitigation checklist for exploit/bench linkage |
| Performance | N/A |
| Downstream | `exploit_http.py` reads `li_invariant` from mitigations table |
