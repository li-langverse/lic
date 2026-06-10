# Real website TLS proxy integration

Models a typical static site behind li-httpd: HTML index with **19** linked CSS, JS, and font assets fetched in parallel (browser-like).

```
curl (tester) --TLS--> li-httpd (proxy) --HTTP--> nginx (backend)
                         :8443                      :8080
```

## Run (from `lic/`)

```bash
docker compose -f test/integration/real-sites/docker-compose.yml build
docker compose -f test/integration/real-sites/docker-compose.yml up --abort-on-container-exit tester
```

Or via the suite runner:

```bash
sh test/proxy/run-proxy-tests.sh --real-site
```

## Pass criteria

- `test-real-website-parallel.sh`: index **200**, **≥18** asset URLs discovered, all parallel fetches **200** with `wc -c` == `Content-Length`.
