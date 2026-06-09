# TLS proxy relay test suite

Formal gate for li-httpd TLS edge relay: wbio drain, CL byte accounting, upstream hold, 381B final-chunk tail, parallel fetches.

Coordinates with [TDD proxy fix pipeline](https://github.com/li-langverse/lic) C oracles in `test/proxy-relay/` and docker repro in `test/proxy-repro/`.

## Run (from `lic/`)

```bash
# C unit oracles only (no docker, fast — CI default)
make test-proxy-c
# or
sh test/proxy/run-proxy-tests.sh --c-only

# Full suite: C oracles + docker compose integration
make test-proxy

# Host integration only (proxy already on PROXY_PORT)
PROXY_PORT=18443 sh test/proxy/run-proxy-tests.sh --integration-only --skip-docker
```

## Tests

| Test | Script | Pass criteria |
|------|--------|---------------|
| `test_tls_wbio_drain` | `test/proxy-relay/test_tls_wbio_drain.sh` | C oracle: relay pending while TLS defer > 0 |
| `test_final_chunk_tail` | `test/proxy-relay/test_final_chunk_tail.sh` | C selftest: 381B rbuf tail not dropped |
| `test_proxy_cl_accounting` | `test/proxy-relay/test_proxy_cl_accounting.sh` | C oracle: CL decrement tracks consumed bytes |
| `test_proxy_upstream_hold` | `test/proxy-relay/test_proxy_upstream_hold.sh` | C oracle: hold while TLS client backlog |
| `test_cl_cap_no_desync` | `test/proxy-relay/test_cl_cap_no_desync.sh` | C selftest: body_left not desynced from cap |
| `test_parallel_same_asset` | `test/proxy-relay/test_parallel_same_asset.sh` | N=6 parallel, `wc -c` == Content-Length |
| `test_parallel_multi_asset` | `test/proxy-relay/test_parallel_multi_asset.sh` | 18 URLs parallel, all sizes match |

## CI

- GitHub `httpd-ci-runtime` workflow runs `make test-proxy-c` on `runtime/li_rt_net.c` changes.
- GitLab `test-proxy` job (MR + `feat/dynamic-httpd-routes`) runs the same C gate.

## Related

- `test/proxy-repro/` — docker edge chain repro (sequential + parallel)
- `test/proxy-relay/README.md` — per-script details
- `homelab-k3s` — `npm run test:edge-parallel` for live cluster gate
