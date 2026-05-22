#!/usr/bin/env bash
# Ensure the lic CI Docker image exists locally (pull public GHCR, else build).
# No credentials are read or stored — publish uses GITHUB_TOKEN only in GHA.
#
# Usage:
#   ./scripts/prepare-docker-ci-image.sh          # pull or build if missing
#   ./scripts/prepare-docker-ci-image.sh --pull   # pull only (fail if unavailable)
#   ./scripts/prepare-docker-ci-image.sh --build  # build from docker/ci-ubuntu24-llvm22
#
# Env:
#   LI_CI_DOCKER_IMAGE  default ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${LI_CI_DOCKER_IMAGE:-ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22}"
MODE="${1:-}"

resolve_container_runtime() {
  if [[ -n "${CONTAINER_RUNTIME:-}" ]]; then
    echo "$CONTAINER_RUNTIME"
    return 0
  fi
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo docker
    return 0
  fi
  if command -v podman >/dev/null 2>&1 && podman info >/dev/null 2>&1; then
    echo podman
    return 0
  fi
  return 1
}

CTR="$(resolve_container_runtime)" || {
  echo "prepare-docker-ci-image: need docker or podman (socket access / rootless ok)" >&2
  exit 1
}

image_ready() {
  "$CTR" image inspect "$IMAGE" >/dev/null 2>&1
}

if image_ready; then
  echo "prepare-docker-ci-image: already present $IMAGE"
  "$CTR" image inspect "$IMAGE" --format '  size={{.Size}} created={{.Created}}'
  exit 0
fi

if [[ "$MODE" != "--build" ]]; then
  echo "prepare-docker-ci-image: pulling $IMAGE"
  if "$CTR" pull "$IMAGE"; then
    echo "prepare-docker-ci-image: ok (pulled)"
    exit 0
  fi
  if [[ "$MODE" == "--pull" ]]; then
    echo "prepare-docker-ci-image: pull failed (image may not be published yet)" >&2
    exit 1
  fi
  echo "prepare-docker-ci-image: pull failed — building locally (set LI_CI_DOCKER_BUILD=1 to skip pull)" >&2
fi

echo "prepare-docker-ci-image: building $IMAGE"
"$CTR" build -t "$IMAGE" "$ROOT/docker/ci-ubuntu24-llvm22"
echo "prepare-docker-ci-image: ok (built via $CTR)"
"$CTR" image inspect "$IMAGE" --format '  size={{.Size}}'
