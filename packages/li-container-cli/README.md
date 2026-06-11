# li-container-cli (`lictl`)

User-facing container CLI: pull OCI images from any registry, run, ps, stop. Low-level OCI lifecycle commands delegate to `lirun`.

## Build

```bash
lic build src/main.li -o lictl
```

## Pull (any OCI v2 registry)

```bash
# GHCR (li-langverse images)
export GHCR_TOKEN=...   # or LI_REGISTRY_TOKEN, GH_PACKAGES, GH_TOKEN
lictl pull ghcr.io/li-langverse/some-image:tag --bundle ./mybundle

# Red Hat registry
export LI_REGISTRY_USER=... LI_REGISTRY_PASS=...
lictl pull registry.redhat.io/ubi9/ubi:latest --bundle ./ubi-bundle

# Docker Hub (short name → docker.io/library/...)
lictl pull alpine:3.19 --bundle ./alpine

# Private registry — docker config or explicit creds
export LI_REGISTRY_AUTH_FILE=~/.docker/config.json
lictl pull registry.example.com/team/app:v1 --bundle ./app

# Dry-run (no network; writes minimal bundle)
export LI_OCI_PULL_DRY_RUN=1
lictl pull ghcr.io/foo:bar --bundle ./dry
```

Requires on Linux: **skopeo + umoci**, or **podman** fallback. Set `LIC_ROOT` to the `lic` repo so `scripts/oci-pull-to-bundle.sh` is found.

## Run

```bash
# From an existing bundle
lictl run --bundle ./mybundle --id mybox

# Pull image then run (stores bundle under LI_CONTAINER_IMAGE_STORE/<id>)
export LI_CONTAINER_IMAGE_STORE=/var/lib/li-container/bundles
lictl run --image ghcr.io/li-langverse/foo:tag --id mybox
```

## Other commands

```bash
lictl version
lictl ps
lictl stop --id mybox
lictl create --bundle ... --id ...   # lirun OCI dispatch
```

## License

Apache-2.0 OR MIT
