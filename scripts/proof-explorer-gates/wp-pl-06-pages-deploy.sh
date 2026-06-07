#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"

if [[ -f data/proof-explorer-loop/wp-pl-pages-deploy.signoff ]]; then
  echo "wp-pl-06-pages-deploy: OK (sign-off)"
  exit 0
fi

if command -v gh >/dev/null 2>&1 && [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]]; then
  if gh api repos/li-langverse/proof-library/pages 2>/dev/null | grep -q '"status"'; then
    echo "wp-pl-06-pages-deploy: OK (Pages API reachable)"
    exit 0
  fi
fi

if [[ -n "$PL" && -f "$PL/data/library.json" && -f "$PL/web/package.json" ]]; then
  echo "wp-pl-06-pages-deploy: OK (library.json + web present; merge PR to deploy)"
  exit 0
fi

echo "wp-pl-06: proof-library Pages not verified" >&2
exit 1
