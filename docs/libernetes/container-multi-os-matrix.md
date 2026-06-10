# Container multi-OS matrix

Support matrix for **li-container** + **li-container-run** (`lirun`) backends across Linux, LiOS, Windows, and macOS. Wave 1 (P2) shipped backend tags and selection stubs; P5 adds host detection, capability scores, and libernetes scheduling labels.

## Backends

| Backend | Module | Tag (`backend/select.li`) | Host signal | Isolation primitives |
|---------|--------|--------------------------|-------------|----------------------|
| Linux | `packages/li-container/src/backend/linux.li` | `1` | `__linux__` (not LiOS) | namespaces, cgroups v2, seccomp BPF (`runtime/li_rt_container.c`) |
| LiOS | `packages/li-container/src/backend/lios.li` | `2` | `LI_CONTAINER_OS=lios` or `LIBERNETES_OS=lios` | jail, cgroup, namespaces |
| Windows | `packages/li-container/src/backend/windows.li` | `3` | `_WIN32` or `LI_CONTAINER_OS=windows` | job objects, silo namespaces |
| macOS | `packages/li-container/src/backend/darwin.li` | `4` | `__APPLE__` or `LI_CONTAINER_OS=darwin` | sandbox, VM fallback (Virt.framework planned) |

Trusted C runtime stays in `lic/runtime/li_rt_container.c`; package repos expose pure-Li capability tags only.

## Host OS × architecture

| Host OS | Arch | Backend | Worker label | P5 status |
|---------|------|---------|--------------|-----------|
| Linux | amd64 | Linux | `libernetes.io/container=true` | full lifecycle via `lirun` + Linux RT |
| Linux | arm64 | Linux | `libernetes.io/container=true` | full lifecycle via `lirun` + Linux RT |
| LiOS | amd64 | LiOS | `libernetes.io/os=lios` | create/start stubs; jail+cgroup tags |
| LiOS | arm64 | LiOS | `libernetes.io/os=lios` | create/start stubs |
| Windows | amd64 | Windows | `libernetes.io/os=windows` | create/start stubs; job-object tags |
| macOS | arm64 | macOS | `libernetes.io/os=darwin` | create/start stubs; sandbox tags |
| macOS | amd64 | macOS | `libernetes.io/os=darwin` | create/start stubs |

LiOS is detected before generic Linux so LiOS-kernel workers do not fall through to the Linux backend.

## Backend detection order

1. `container_is_lios_i()` — env `LI_CONTAINER_OS` / `LIBERNETES_OS` = `lios`
2. `container_is_linux_i()` — `__linux__` when not LiOS
3. `container_is_windows_i()` — `_WIN32` or env override
4. `container_is_darwin_i()` — `__APPLE__` or env override
5. unknown → `container_backend_id_unknown()`

Override for CI/dev: `LI_CONTAINER_OS=lios|windows|darwin`.

## Package split

| Repo | Import | Role |
|------|--------|------|
| `li-oci` | `oci` | image layout, manifest, pull/store |
| `li-container` | `container` | bundle, state, backend selection |
| `li-container-run` | `container.run` | `lirun` lifecycle (backend-aware) |

## Scheduling

- **RuntimeClass** values: `container` (see [heterogeneous-workers.md](heterogeneous-workers.md)).
- Scheduler matches `WorkerProfile` capabilities (`container`, `kvm`) and node labels to pod specs.
- Container workers require `libernetes.io/container=true`; LiOS workers use `libernetes.io/os=lios`.

## Verification

```bash
bash scripts/container-separate-repos-phase5-gate.sh
bash scripts/container-separate-repos-completion-gate.sh
```
