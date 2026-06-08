# Homelab edge ingress limits

Raise runtime caps and defer blocking upstream prewarm at config load so li-httpd can start when some k3s NodePort backends are down (kube-proxy blackhole until pods exist).

| Change | Old | New |
|--------|-----|-----|
| `HTTPD_MAX_ROUTES` | 16 | 128 |
| `HTTPD_MAX_UPSTREAM_PEERS` | 8 | 32 |
| Prewarm at `httpd_load_runtime_config` | sync connect all pool fds | skipped (lazy connect on first request) |

Multi-vhost / named upstream pools (`[[site]]`, `upstream_pool=`, `route=...|pool|vhost`) are required for homelab edge; use the lic tree deployed on blackpearl (`~/staging/lic`) which includes the vhost runtime loader.

Rebuild after pull:

```bash
bash scripts/build-li-httpd.sh
sudo install -m 0755 build/li-httpd /usr/local/bin/li-httpd
```

Or on blackpearl: `bash ~/staging/majico.xyz/deploy/staging/scripts/build-li-httpd.sh`
