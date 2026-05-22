# Local CI — prebuilt Docker images (GHCR)

**Goal:** New machines run `./scripts/local-ci.sh --docker` without apt/llvm install on every run.

## Image

| Registry | Tag | Contents |
|----------|-----|----------|
| `ghcr.io/li-langverse/lic-ci` | `ubuntu24-llvm22`, `latest` | Ubuntu 24.04, LLVM 22, cmake, ninja, python3, zlib/zstd dev |

Built from `docker/ci-ubuntu24-llvm22/Dockerfile` (same toolchain as `scripts/ci-install-llvm.sh`).

## On a new machine

```bash
cd lic
./scripts/prepare-docker-ci-image.sh   # docker pull (public) or local build
./scripts/local-ci.sh --docker
```

Override image:

```bash
export LI_CI_DOCKER_IMAGE=ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22
```

**Docker group:** user must access `/var/run/docker.sock` (e.g. `sudo usermod -aG docker $USER` then re-login). No tokens are stored in the repo.

## Publish (maintainers)

Workflow `.github/workflows/publish-docker-ci-image.yml` pushes to GHCR using **`GITHUB_TOKEN`** in Actions only. Do not commit `GHCR_TOKEN`, `.env` credentials, or `docker login` output.

Trigger manually: **Actions → Publish CI Docker image → Run workflow**.

After the first publish, `docker pull ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22` works without login for public packages.

## OS coverage

| Layer | Coverage |
|-------|----------|
| This image | Linux / GHA `ubuntu-24.04` job only |
| `./scripts/local-ci.sh` (native) | Host OS (Linux or macOS) |
| GHA `macos-14` / `windows-latest` | Not in this image — still need GHA or real runners |

## li-local-ci

Set `LI_LOCAL_CI_IMAGE=ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22` in profile `lic-docker` (see `li-local-ci` repo) for act/profile docker runs.
