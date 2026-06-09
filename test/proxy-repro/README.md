# li-httpd TLS proxy repro

Models the homelab edge chain without blackpearl/K8s/Fritz:

```
curl (tester) --TLS--> li-httpd (proxy) --HTTP--> nginx (backend)
                         :8443                      :8080
```

The backend serves `/users/sign_in` (HTML referencing CSS) and `/assets/application-deadbeef.css` at **835437 bytes** — same probe size as GitLab edge acceptance.

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

`run-test.sh` exits 0 on **10/10** runs: sign-in **200/302**, CSS `size_download` **835437**.
