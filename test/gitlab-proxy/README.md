# GitLab TLS proxy integration (isolated)

Isolated docker chain for GitLab-style sign_in page loads through li-httpd — without a full GitLab Omnibus boot.

```
curl (tester) --TLS--> li-httpd (proxy) --HTTP--> nginx (GitLab asset mimic)
                         :8443                      :8080
```

Uses the same 18-asset inventory as `test/proxy-repro/gen-asset.py` (GitLab sign_in representative sizes).

## Run (from `lic/`)

```bash
docker compose -f test/gitlab-proxy/docker-compose.yml build
docker compose -f test/gitlab-proxy/docker-compose.yml up --abort-on-container-exit tester
```

Or:

```bash
sh test/proxy/run-proxy-tests.sh --gitlab
```

## Pass criteria

- `/users/sign_in` returns HTML with linked stylesheets
- **18** parallel asset fetches: all **200**, `wc -c` == `Content-Length`

## Live cluster alternative

For real GitLab Omnibus behind the homelab edge (not this compose stack), use `homelab-k3s`:

```bash
cd homelab-k3s && npm test
```

That runs curl + Playwright gates against `gitlab.lilangverse.xyz` on the k3s cluster (Layer 6).

## Full GitLab CE container (manual)

A full `gitlab/gitlab-ce` container takes several minutes to boot and is not run in CI. To test manually:

1. Start `gitlab/gitlab-ce` on port 8080 with `GITLAB_OMNIBUS_CONFIG` external URL.
2. Point `test/gitlab-proxy/proxy/httpd.toml` upstream peer at the container IP.
3. Run `test-gitlab-parallel.sh` against the proxy port.

Or use the k3s GitLab NodePort backend documented in `homelab-k3s/docs/gitlab-homelab.md`.
