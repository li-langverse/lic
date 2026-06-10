# TLS proxy relay test suite

Formal gate for li-httpd TLS edge relay: wbio drain, CL byte accounting, upstream hold, 381B final-chunk tail, parallel fetches.

## Integration test pyramid

| Layer | Flag | Target | Pass criteria |
|-------|------|--------|---------------|
| 1 Unit | `--unit` / `--c-only` | C oracles in `test/proxy-relay/` | 5/5 C selftests |
| 2 Real site | `--real-site` | `test/integration/real-sites/` | 18+ parallel assets, wc -c |
| 3 Next.js | `--nextjs` | `test/nextjs-proxy/` | 18+ `_next/static/*` chunks |
| 4 GitLab | `--gitlab` | `test/gitlab-proxy/` | sign_in + 18 assets |
| 5 Load balancer | `--lb` | `test/proxy-repro/docker-compose.lb.yml` | RR/LC ≥2 backends; ip_hash =1 |
| 6 Cluster | — | `homelab-k3s && npm test` | live edge gates (required for TESTED) |

## Run (from `lic/`)

```bash
# Layer 1 only (CI default)
make test-proxy-c

# Individual docker layers
sh test/proxy/run-proxy-tests.sh --real-site
sh test/proxy/run-proxy-tests.sh --nextjs
sh test/proxy/run-proxy-tests.sh --gitlab
sh test/proxy/run-proxy-tests.sh --lb

# Layers 1 + 2–5 (docker required)
sh test/proxy/run-proxy-tests.sh --all

# Host integration only (proxy already on PROXY_PORT)
PROXY_PORT=18443 sh test/proxy/run-proxy-tests.sh --integration-only --skip-docker
```

## C unit tests

| Test | Script | Pass criteria |
|------|--------|---------------|
| `test_tls_wbio_drain` | `test/proxy-relay/test_tls_wbio_drain.sh` | C oracle: relay pending while TLS defer > 0 |
| `test_final_chunk_tail` | `test/proxy-relay/test_final_chunk_tail.sh` | C selftest: 381B rbuf tail not dropped |
| `test_proxy_cl_accounting` | `test/proxy-relay/test_proxy_cl_accounting.sh` | C oracle: CL decrement tracks consumed bytes |
| `test_proxy_upstream_hold` | `test/proxy-relay/test_proxy_upstream_hold.sh` | C oracle: hold while TLS client backlog |
| `test_cl_cap_no_desync` | `test/proxy-relay/test_cl_cap_no_desync.sh` | C selftest: body_left not desynced from cap |

## CI

- GitHub `httpd-ci-runtime` workflow runs `make test-proxy-c` on `runtime/li_rt_net.c` changes.
- GitLab `test-proxy` job runs the same C gate.

## Related

- `test/proxy-repro/` — docker edge chain repro (sequential + parallel)
- `test/integration/real-sites/` — real website parallel asset gate
- `test/nextjs-proxy/` — Next.js chunk parallel gate
- `test/gitlab-proxy/` — GitLab sign_in isolated gate
- `homelab-k3s` — Layer 6 cluster gates (`npm test`)
