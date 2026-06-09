# TLS proxy relay unit + integration tests (TDD)

Validates li-httpd TLS edge relay: wbio drain before finish, CL byte accounting, upstream hold, parallel fetches.

## Run (from `lic/`)

```bash
# C invariants only (no docker)
sh test/proxy-relay/run-unit-tests.sh --c-only

# Full suite (builds oracle + docker proxy-repro integration)
sh test/proxy-relay/run-unit-tests.sh

# Integration only (proxy must be listening on PROXY_PORT)
PROXY_PORT=18443 sh test/proxy-relay/run-unit-tests.sh --integration-only
```

## Tests

| Test | Script | Pass criteria |
|------|--------|---------------|
| `test_tls_wbio_drain` | `test_tls_wbio_drain.sh` | C oracle: relay pending while defer>0 |
| `test_final_chunk_tail` | `test_final_chunk_tail.sh` | C selftest: 381B rbuf tail not dropped |
| `test_proxy_cl_accounting` | `test_proxy_cl_accounting.sh` | C oracle: CL decrement + cap |
| `test_proxy_upstream_hold` | `test_proxy_upstream_hold.sh` | C oracle: hold while TLS outstanding |
| `test_cl_cap_no_desync` | `test_cl_cap_no_desync.sh` | C selftest: body_left not desynced from cap |
| `test_parallel_same_asset` | `test_parallel_same_asset.sh` | N=6 parallel, `wc -c` == Content-Length |
| `test_parallel_multi_asset` | `test_parallel_multi_asset.sh` | 18 URLs parallel, all sizes match |

Expect **red** on unfixed runtime; **green** after `runtime/li_rt_net.c` TLS CL defer fix.
