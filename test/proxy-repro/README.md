# li-httpd TLS proxy repro

Models the homelab edge chain without blackpearl/K8s/Fritz:

```
curl (tester) --TLS--> li-httpd (proxy) --HTTP--> nginx (backend)
                         :8443                      :8080
```

The backend serves `/users/sign_in` with **6 assets** (3 CSS + 3 JS) spanning **460 B – 1.3 MB** — sizes taken from GitLab `sign_in`.

## Quick run (Docker)

From `lic/`:

```bash
docker compose -f test/proxy-repro/docker-compose.yml build
docker compose -f test/proxy-repro/docker-compose.yml up --abort-on-container-exit tester
```

First proxy image build compiles `lic` + `li-httpd` inside `ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22` (~15–30 min).

## Host loopback (after local build)

```bash
./scripts/build-li-httpd.sh
python3 test/proxy-repro/gen-asset.py --out-dir /tmp/proxy-repro-www
# start backend + proxy manually, then:
PROXY_HOST=127.0.0.1 PROXY_PORT=18443 sh test/proxy-repro/run-test.sh
```

## What we're testing

- TLS reverse proxy relay of ~835KB `Content-Length` bodies
- Rapid sequential requests (10×) with connection reuse patterns
- Multi-site config (`[[site]]`) — snap cache off, `Connection: close` stabilizer (edge-like)

## Pass criteria

- `run-test.sh`: **10/10** sequential runs (sign-in **200/302**, large CSS **835437** bytes).
- `parallel-run-test.sh`: **6/6** parallel CSS+JS fetches (browser-like load).

## Two-backend load balancer e2e

```bash
# All three policies (via suite runner)
sh test/proxy/run-proxy-tests.sh --lb

# Single policy
LB_POLICY=ip_hash docker compose -f test/proxy-repro/docker-compose.lb.yml up --abort-on-container-exit lb-tester
```

`test-lb-e2e.sh` runs **24** requests per policy:

| Policy | Expected distinct `X-Li-Backend` |
|--------|----------------------------------|
| `round_robin` | ≥ 2 (both peer-a and peer-b) |
| `least_conn` | ≥ 2 |
| `ip_hash` | 1 (sticky per client IP) |
