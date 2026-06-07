# Mirror only — do not develop here

**li-httpd is developed in https://github.com/li-langverse/li-httpd**

This folder exists for lic monorepo CI and historical checkout. **lic is the compiler only** — no new httpd, net, or TLS logic in C (`runtime/li_rt_*.c`) or in this package.

Contributors: open PRs on **li-httpd** and sibling Li repos (`li-net`, `li-tls`, …).

Optional sync from upstream: `python scripts/sync-li-httpd-standalone.py` run **from lic** copies **into** li-httpd, not the other way around as source of truth.
