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

if ! command -v docker >/dev/null 2>&1; then
  echo "prepare-docker-ci-image: docker not found" >&2
  exit 1
fi

image_ready() {
  docker image inspect "$IMAGE" >/dev/null 2>&1
}

if image_ready; then
  echo "prepare-docker-ci-image: already present $IMAGE"
  docker image inspect "$IMAGE" --format '  size={{.Size}} created={{.Created}}'
  exit 0
fi

if [[ "$MODE" != "--build" ]]; then
  echo "prepare-docker-ci-image: pulling $IMAGE"
  if docker pull "$IMAGE"; then
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
docker build -t "$IMAGE" "$ROOT/docker/ci-ubuntu24-llvm22"
echo "prepare-docker-ci-image: ok (built)"
docker image inspect "$IMAGE" --format '  size={{.Size}}'
