#!/usr/bin/env bash
# Sync HTTP/TLS/crypto packages from lic monorepo into lis + standalone li-httpd.
# Usage: ./scripts/sync-http-ecosystem-upgrade.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIS_ROOT="${LIS_ROOT:-$ROOT/../lis}"
LI_HTTPD_ROOT="${LI_HTTPD_ROOT:-$ROOT/../li-httpd}"
LIC_COMMIT="$(git -C "$ROOT" rev-parse HEAD)"
LIC_SHORT="$(git -C "$ROOT" rev-parse --short HEAD)"
LIC_VERSION="$(tr -d '\r\n' <"$ROOT/VERSION")"

if [[ ! -d "$LIS_ROOT" ]]; then
  echo "error: LIS_ROOT missing: $LIS_ROOT" >&2
  exit 1
fi
if [[ ! -d "$LI_HTTPD_ROOT" ]]; then
  echo "error: LI_HTTPD_ROOT missing: $LI_HTTPD_ROOT" >&2
  exit 1
fi

rsync_pkg() {
  local src_name="$1"
  local dest_rel="$2"
  local src="$ROOT/packages/$src_name"
  local dest="$LIS_ROOT/packages/$dest_rel"
  if [[ ! -d "$src" ]]; then
    echo "skip (missing in lic): $src_name"
    return 0
  fi
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude='.git' "$src/" "$dest/"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -a "$src/." "$dest/"
  fi
  echo "synced $src_name -> lis/packages/$dest_rel"
}

LIS_PACKAGES=(
  li-bytes
  li-net
  li-rng
  li-prob
  li-crypto
  li-tls
  li-acme
  li-schema
  li-log
  li-http
)

for pkg in "${LIS_PACKAGES[@]}"; do
  rsync_pkg "$pkg" "$pkg"
done

rsync_pkg "li-net-httpd" "li-httpd"

write_toolchain() {
  local dest="$1"
  cat >"$dest" <<EOF
# Pin lic / lit for reproducible CI (synced from lic @ ${LIC_SHORT}).
[toolchain]
lic_version = "${LIC_VERSION}"
lic_commit = "${LIC_COMMIT}"
lit_version = "0.1.0"
EOF
}

write_toolchain "$LIS_ROOT/li-toolchain.toml"
write_toolchain "$LI_HTTPD_ROOT/li-toolchain.toml"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete \
    --exclude='.git' \
    --exclude='li-toolchain.toml' \
    "$ROOT/packages/li-net-httpd/" "$LI_HTTPD_ROOT/"
else
  echo "error: rsync required for standalone li-httpd sync" >&2
  exit 1
fi

write_toolchain "$LI_HTTPD_ROOT/li-toolchain.toml"

if [[ -f "$LI_HTTPD_ROOT/li.toml" ]]; then
  sed -i.bak \
    -e 's/^github_repo = "li-net-httpd"/github_repo = "li-httpd"/' \
    -e 's|github.com/li-langverse/li-net-httpd|github.com/li-langverse/li-httpd|g' \
    "$LI_HTTPD_ROOT/li.toml" 2>/dev/null || true
  rm -f "$LI_HTTPD_ROOT/li.toml.bak"
fi

echo "sync-http-ecosystem-upgrade: ok (lic ${LIC_SHORT})"
echo "  lis:      $LIS_ROOT"
echo "  li-httpd: $LI_HTTPD_ROOT"
