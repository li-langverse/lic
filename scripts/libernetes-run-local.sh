#!/usr/bin/env bash
# libernetes-run-local — single-node control plane stack (Wave 3).
# Starts or dry-runs apiserver, scheduler, kubelet, and runtime daemons locally.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=1
BIND_ADDRESS="127.0.0.1"
APISERVER_PORT="6443"

usage() {
  cat <<EOF
Usage: libernetes-run-local.sh [--start] [--bind-address ADDR] [--apiserver-port PORT]

Run a single-node libernetes stack on the local machine (Wave 3).

Options:
  --start               start daemons (default: dry-run plan only)
  --bind-address ADDR   apiserver bind address (default: 127.0.0.1)
  --apiserver-port PORT apiserver port (default: 6443)
  -h, --help            show this help

Wave 3 default is dry-run: prints the daemon plan without binding ports.
EOF
}

die() {
  echo "libernetes-run-local: $*" >&2
  exit 1
}

require_scaffold() {
  local missing=0
  for pkg in li-libernetes-core li-libernetes-apiserver li-libernetes-scheduler li-libernetes-kubelet; do
    if [[ ! -f "$ROOT/packages/$pkg/li.toml" ]]; then
      echo "libernetes-run-local: missing package scaffold: $pkg" >&2
      missing=1
    fi
  done
  [[ "$missing" -eq 0 ]] || die "required libernetes packages missing; run from lic repo root"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --start)
      DRY_RUN=0
      shift
      ;;
    --bind-address)
      [[ $# -ge 2 ]] || die "missing value for --bind-address"
      BIND_ADDRESS="$2"
      shift 2
      ;;
    --apiserver-port)
      [[ $# -ge 2 ]] || die "missing value for --apiserver-port"
      APISERVER_PORT="$2"
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

require_scaffold

APISERVER_ENDPOINT="${BIND_ADDRESS}:${APISERVER_PORT}"
echo "libernetes-run-local: endpoint=https://${APISERVER_ENDPOINT}"

echo "libernetes-run-local: daemon plan:"
echo "  1. embedded etcd (data-dir: /var/lib/libernetes/etcd)"
echo "  2. li-libernetes-apiserver on ${APISERVER_ENDPOINT} (informer_sync wired)"
echo "  3. li-libernetes-scheduler (leader election stub)"
echo "  4. li-libernetes-kubelet (sync.li apiserver↔node loop)"
echo "  5. licontainers CRI socket (/var/run/libernetes/cri.sock)"
echo "  6. livm hypervisor socket (/var/run/libernetes/livm.sock)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "libernetes-run-local: dry-run OK (pass --start to bind ports in a later wave)"
  exit 0
fi

echo "libernetes-run-local: --start requested (Wave 3: process spawn not implemented yet)"
bash "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes-run-local: OK (scaffold verified — daemons not spawned in Wave 3)"
