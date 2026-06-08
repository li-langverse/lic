#!/usr/bin/env bash
# libernetes init — control plane bootstrap (Wave 1 scaffold).
# Mirrors: libernetes init --profile homelab|ha [--bind-address ADDR]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROFILE=""
BIND_ADDRESS="127.0.0.1"
KUBECONFIG_PATH="/etc/libernetes/admin.conf"

usage() {
  cat <<EOF
Usage: libernetes init --profile homelab|ha [--bind-address ADDR]

Bootstrap a libernetes control plane (Wave 1 scaffold — prints planned steps).

Profiles:
  homelab   single-node control plane with embedded etcd
  ha        multi-node control plane (3+ apiserver/etcd members)

Options:
  --bind-address ADDR   apiserver bind address (default: 127.0.0.1)
  -h, --help            show this help

After init, set KUBECONFIG and verify:
  export KUBECONFIG=${KUBECONFIG_PATH}
  libernetes doctor
EOF
}

die() {
  echo "libernetes init: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    init) shift ;;
    --profile)
      [[ $# -ge 2 ]] || die "missing value for --profile"
      PROFILE="$2"
      shift 2
      ;;
    --bind-address)
      [[ $# -ge 2 ]] || die "missing value for --bind-address"
      BIND_ADDRESS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1 (try --help)"
      ;;
  esac
done

[[ -n "$PROFILE" ]] || die "--profile is required (homelab or ha)"

case "$PROFILE" in
  homelab|ha) ;;
  *) die "unsupported profile: $PROFILE (expected homelab or ha)" ;;
esac

if [[ ! -f "$ROOT/packages/li-libernetes-core/li.toml" ]]; then
  die "li-libernetes-core scaffold missing; run from lic repo root"
fi

echo "libernetes init: profile=$PROFILE bind-address=$BIND_ADDRESS"
echo "libernetes init: planned steps (Wave 1 scaffold):"
echo "  1. generate PKI + bootstrap tokens"
echo "  2. start embedded etcd (profile=$PROFILE)"
echo "  3. start li-libernetes-apiserver on ${BIND_ADDRESS}:6443"
echo "  4. start li-libernetes-kubelet (control-plane node)"
echo "  5. apply WorkerProfile CRD from docs/libernetes/crd-workerprofile.yaml"
echo "  6. write admin kubeconfig -> ${KUBECONFIG_PATH}"

if [[ "$PROFILE" == "ha" ]]; then
  echo "  7. join additional control-plane members (manual LB-K6+)"
fi

bash "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes init: OK (scaffold complete — packages not started in Wave 1)"
