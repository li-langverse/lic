#!/usr/bin/env bash
# libernetes worker join — heterogeneous worker registration (Wave 1 scaffold).
# Mirrors: libernetes worker join <cp-url> --token <token> --profile auto|...
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JOIN_URL=""
TOKEN=""
PROFILE="auto"
KUBELET_CONF="${LIBERNETES_KUBELET_CONF:-/etc/libernetes/kubelet.conf}"

usage() {
  cat <<EOF
Usage: libernetes worker join <control-plane-url> --token <token> [--profile NAME]

Register a heterogeneous worker with auto-discovered capabilities (Wave 1 scaffold).

Arguments:
  <control-plane-url>   apiserver endpoint (e.g. https://cp.homelab.lan:6443)

Options:
  --token TOKEN         bootstrap join token (required)
  --profile NAME        WorkerProfile name (default: auto)
  -h, --help            show this help

Auto-discovered node labels (see docs/libernetes/heterogeneous-workers.md):
  libernetes.io/arch, libernetes.io/hypervisor, libernetes.io/container, libernetes.io/gpu, libernetes.io/os
EOF
}

die() {
  echo "libernetes worker join: $*" >&2
  exit 1
}

detect_arch() {
  local raw
  raw="$(uname -m)"
  case "$raw" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) echo "$raw" ;;
  esac
}

detect_hypervisor() {
  # Li-native hypervisor only — KVM/QEMU probing removed from target architecture.
  if [[ -f /etc/lios-release ]]; then
    echo "li-native"
  elif [[ -e /dev/li-hypervisor || -S /var/run/livm/hypervisor.sock ]]; then
    echo "li-native"
  else
    echo "none"
  fi
}

detect_container() {
  if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
    echo "true"
  else
    echo "false"
  fi
}

detect_gpu() {
  if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    echo "true"
  elif [[ -d /dev/vfio ]]; then
    echo "true"
  else
    echo "false"
  fi
}

detect_os() {
  if [[ -f /etc/lios-release ]]; then
    echo "lios"
  else
    echo "linux"
  fi
}

print_labels() {
  local arch hypervisor container gpu os
  arch="$(detect_arch)"
  hypervisor="$(detect_hypervisor)"
  container="$(detect_container)"
  gpu="$(detect_gpu)"
  os="$(detect_os)"

  echo "libernetes worker join: discovered capabilities:"
  echo "  libernetes.io/arch=$arch"
  echo "  libernetes.io/hypervisor=$hypervisor"
  echo "  libernetes.io/container=$container"
  echo "  libernetes.io/gpu=$gpu"
  echo "  libernetes.io/os=$os"
}

write_kubelet_conf() {
  local arch hypervisor container gpu os
  arch="$(detect_arch)"
  hypervisor="$(detect_hypervisor)"
  container="$(detect_container)"
  gpu="$(detect_gpu)"
  os="$(detect_os)"

  local conf_dir
  conf_dir="$(dirname "$KUBELET_CONF")"
  if [[ ! -d "$conf_dir" ]]; then
    if mkdir -p "$conf_dir" 2>/dev/null; then
      :
    elif [[ -n "${LIBERNETES_KUBELET_CONF:-}" ]]; then
      die "cannot create kubelet config directory: $conf_dir"
    else
      KUBELET_CONF="${ROOT}/.libernetes/kubelet.conf"
      conf_dir="$(dirname "$KUBELET_CONF")"
      mkdir -p "$conf_dir" || die "cannot create kubelet config directory: $conf_dir"
      echo "libernetes worker join: /etc/libernetes not writable; using $KUBELET_CONF" >&2
    fi
  fi

  cat >"$KUBELET_CONF" <<EOF
# libernetes kubelet config — written by libernetes-worker-join.sh (Wave 4)
apiServer: ${JOIN_URL}
profile: ${PROFILE}
bootstrapToken: ${TOKEN}
criSocket: /var/run/libernetes/cri.sock
livmSocket: /var/run/libernetes/livm.sock
labels:
  libernetes.io/arch: ${arch}
  libernetes.io/hypervisor: ${hypervisor}
  libernetes.io/container: ${container}
  libernetes.io/gpu: ${gpu}
  libernetes.io/os: ${os}
EOF

  echo "libernetes worker join: wrote kubelet config -> ${KUBELET_CONF}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    worker)
      shift
      [[ $# -ge 1 && "$1" == "join" ]] || die "expected 'worker join' subcommand"
      shift
      ;;
    join)
      shift
      ;;
    --token)
      [[ $# -ge 2 ]] || die "missing value for --token"
      TOKEN="$2"
      shift 2
      ;;
    --profile)
      [[ $# -ge 2 ]] || die "missing value for --profile"
      PROFILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    http://*|https://*)
      JOIN_URL="$1"
      shift
      ;;
    *)
      die "unknown argument: $1 (try --help)"
      ;;
  esac
done

[[ -n "$JOIN_URL" ]] || die "control-plane URL is required"
[[ -n "$TOKEN" ]] || die "--token is required"

case "$PROFILE" in
  auto|homelab|ha|default-auto|vm-gpu-pool) ;;
  *)
    if [[ ! -f "$ROOT/docs/libernetes/crd-workerprofile.yaml" ]]; then
      die "unknown profile: $PROFILE"
    fi
    ;;
esac

if [[ ! -f "$ROOT/packages/li-libernetes-kubelet/li.toml" ]]; then
  die "li-libernetes-kubelet scaffold missing; run from lic repo root"
fi

echo "libernetes worker join: url=$JOIN_URL profile=$PROFILE"
print_labels
write_kubelet_conf

echo "libernetes worker join: planned steps (Wave 4):"
echo "  1. validate bootstrap token with apiserver at $JOIN_URL"
echo "  2. kubelet config persisted at ${KUBELET_CONF}"
echo "  3. apply WorkerProfile '$PROFILE' and node labels"
echo "  4. start li-libernetes-kubelet and report NodeReady"

bash "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes worker join: OK (kubelet.conf written — kubelet start in Wave 5+)"
