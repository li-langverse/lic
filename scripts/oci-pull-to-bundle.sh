#!/usr/bin/env bash
# Pull an OCI image reference into a runtime bundle (config.json + rootfs/).
# Invoked by lictl via container_registry_pull_i (sets LI_OCI_PULL_REF, LI_OCI_PULL_OUT).
#
# Auth (first match wins):
#   LI_REGISTRY_USER + LI_REGISTRY_PASS
#   LI_REGISTRY_TOKEN (+ optional LI_REGISTRY_USER, default oauth2)
#   GHCR_TOKEN / GH_PACKAGES / GH_TOKEN for ghcr.io refs
#   LI_REGISTRY_AUTH_FILE or ~/.docker/config.json (skopeo --authfile)
#
# Requires: skopeo + umoci (or podman for fallback unpack).
set -euo pipefail

REF="${LI_OCI_PULL_REF:?LI_OCI_PULL_REF required}"
OUT="${LI_OCI_PULL_OUT:?LI_OCI_PULL_OUT required}"

if [[ "${LI_OCI_PULL_DRY_RUN:-}" == "1" ]]; then
  echo "oci-pull dry-run: ref=$REF out=$OUT"
  mkdir -p "$OUT/rootfs"
  cat >"$OUT/config.json" <<EOF
{"ociVersion":"1.0.2","process":{"args":["/bin/sh"],"env":["PATH=/bin"],"cwd":"/"},"root":{"path":"rootfs"}}
EOF
  exit 0
fi

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "oci-pull: Linux required" >&2
  exit 1
fi

normalize_ref() {
  local r="$1"
  if [[ "$r" != *"/"* ]]; then
    echo "docker.io/library/${r}"
    return
  fi
  if [[ "$r" != *"."*"/"* && "$r" != "localhost/"* ]]; then
    echo "docker.io/${r}"
    return
  fi
  echo "$r"
}

REF="$(normalize_ref "$REF")"

SKOPEO_AUTH=()
AUTHFILE="${LI_REGISTRY_AUTH_FILE:-}"
if [[ -z "$AUTHFILE" && -f "${DOCKER_CONFIG:-$HOME/.docker}/config.json" ]]; then
  AUTHFILE="${DOCKER_CONFIG:-$HOME/.docker}/config.json"
fi
if [[ -n "$AUTHFILE" && -f "$AUTHFILE" ]]; then
  SKOPEO_AUTH=(--authfile "$AUTHFILE")
fi

if [[ -n "${LI_REGISTRY_USER:-}" && -n "${LI_REGISTRY_PASS:-}" ]]; then
  SKOPEO_AUTH=(--src-creds "${LI_REGISTRY_USER}:${LI_REGISTRY_PASS}")
elif [[ -n "${LI_REGISTRY_TOKEN:-}" ]]; then
  SKOPEO_AUTH=(--src-creds "${LI_REGISTRY_USER:-oauth2}:${LI_REGISTRY_TOKEN}")
elif [[ "$REF" == ghcr.io/* ]]; then
  for var in GHCR_TOKEN GH_PACKAGES GH_TOKEN; do
    if [[ -n "${!var:-}" ]]; then
      SKOPEO_AUTH=(--src-creds "x-access-token:${!var}")
      break
    fi
  done
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
OCI_DIR="$TMP/oci"
mkdir -p "$OCI_DIR"

pull_skopeo_umoci() {
  command -v skopeo >/dev/null 2>&1 || return 1
  skopeo copy "${SKOPEO_AUTH[@]}" "docker://${REF}" "oci:${OCI_DIR}:dest"
  if command -v umoci >/dev/null 2>&1; then
    mkdir -p "$OUT"
    umoci unpack --image "${OCI_DIR}:dest" "$OUT"
    return 0
  fi
  return 2
}

pull_podman() {
  command -v podman >/dev/null 2>&1 || return 1
  local cid rootfs
  cid="$(podman create "${REF}")"
  rootfs="$(podman mount "$cid")"
  mkdir -p "$OUT/rootfs"
  cp -a "${rootfs}/." "$OUT/rootfs/"
  if ! podman inspect "$cid" --format '{{json .Config}}' >"$OUT/config.json" 2>/dev/null; then
    cat >"$OUT/config.json" <<'EOF'
{"ociVersion":"1.0.2","process":{"terminal":false,"user":{"uid":0,"gid":0},"args":["/bin/sh"],"env":["PATH=/usr/bin:/bin"],"cwd":"/"},"root":{"path":"rootfs","readonly":false},"hostname":"lictl"}
EOF
  fi
  podman umount "$cid" 2>/dev/null || true
  podman rm "$cid" >/dev/null 2>&1 || true
  return 0
}

rc=0
pull_skopeo_umoci || rc=$?
if [[ "$rc" == 0 ]]; then
  echo "oci-pull: ok ref=$REF bundle=$OUT"
  exit 0
fi

if pull_podman; then
  echo "oci-pull: ok (podman) ref=$REF bundle=$OUT"
  exit 0
fi

if [[ "$rc" == 2 ]]; then
  echo "oci-pull: skopeo found but umoci missing — install umoci or podman" >&2
else
  echo "oci-pull: install skopeo+umoci or podman (ref=$REF)" >&2
fi
exit 1
