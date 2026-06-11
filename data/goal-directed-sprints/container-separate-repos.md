---
workflow_repo: lic
branch: feat/extern-def-container-seam
plan: docs/libernetes/master-plan.md
---

# Container separate repos — goal-directed sprint

**Branch:** `feat/container-product-complete`  
**Agent:** `code_implementer`  
**North star:** Split monolithic `licontainers` + librebase `licontainer` into published **`li-oci`**, **`li-container`**, **`li-container-run`** repos; merge trusted Container seam into `lic`; cross-platform backends (Linux, LiOS, Windows, macOS) — pure Li packages + audited C in `lic/runtime/` only.

## Iteration rules

1. Read `data/container-separate-repos-loop/state.json` for the current phase key.
2. Implement **only** that phase's WPs; commit + push to `feat/extern-def-container-seam` every iteration.
3. Run the phase gate before ending the iteration.
4. Append one row to `data/container-separate-repos-loop/iteration-log.md`.
5. Do not mark sprint done until `scripts/container-separate-repos-completion-gate.sh` passes.

## Repo model (required)

| Repo | Import | Owns | Does **not** own |
|------|--------|------|------------------|
| `li-oci` | `oci` | OCI spec, image layout, manifest/config, pull/store | `raises Container`, `lirun`, CRI |
| `li-container` | `container` | bundle, state, runerr, backend selection, seam dev copy | C impl |
| `li-container-run` | `container.run` | `lirun` lifecycle | OCI parsers (depends `li-oci`) |

**Stays in `lic` only:** `std/runtime/seam.li`, `runtime/li_rt_container.c`, `docs/semantics/trusted.lean`, `li-tests/container_trusted/`.

**Port source:** `librebase/licontainer/packages/` (relicense Apache-2.0 OR MIT). **Do not** duplicate OCI in runtime packages.

## Phase checklist

| Phase | Key | WPs | Deliverable | Gate |
|-------|-----|-----|-------------|------|
| **P0** | `p0-seam` | WP-CTN-001..005 | Container seam in `lic`, stub `li_rt_container.c`, `container_trusted` tests, scaffold 3 packages | `bash scripts/container-separate-repos-phase0-gate.sh` |
| **P1** | `p1-li-oci` | WP-CTN-010..013 | `packages/li-oci` — spec, layout, manifest, pull/store (Net only, no Container) | `bash scripts/container-separate-repos-phase1-gate.sh` |
| **P2** | `p2-li-container` | WP-CTN-020..024 | Port librebase core + `backend/{select,linux,lios,windows,darwin}.li` | `bash scripts/container-separate-repos-phase2-gate.sh` |
| **P3** | `p3-linux-rt` | WP-CTN-030..033 | Harden `li_rt_container.c` — unshare, cgroups v2, pivot_root, seccomp | `bash scripts/container-separate-repos-phase3-gate.sh` |
| **P4** | `p4-lirun` | WP-CTN-040..042 | Port `runtime.li` + `main.li`; backend-aware lifecycle | `bash scripts/container-separate-repos-phase4-gate.sh` |
| **P5** | `p5-cross-os` | WP-CTN-050..053 | LiOS / Windows / macOS backends + `docs/libernetes/container-multi-os-matrix.md` | `bash scripts/container-separate-repos-phase5-gate.sh` |
| **P6** | `p6-orchestration` | WP-CTN-060..063 | `li-containerd`/`cli`/`cri` scaffolds; retire `licontainers` monolith | `bash scripts/container-separate-repos-phase6-gate.sh` |
| **P7** | `p7-publish` | WP-CTN-070..074 | GitLab repos + mirror push; update `package-gap-register.md` | `bash scripts/container-separate-repos-phase7-gate.sh` |
| **P8** | `p8-product` | WP-CTN-080..083 | Port librebase runtime + `emit_error_json`; **lictl** CLI (`run`, `ps`, `stop`, `version`) | `bash scripts/container-separate-repos-phase8-gate.sh` |
| **P9** | `p9-integration` | WP-CTN-090..092 | Busybox integration script, `lictl ps` state listing, `--id` argv fixes | `bash scripts/container-separate-repos-phase9-gate.sh` |
| **P10** | `p10-pull` | WP-CTN-100..102 | `lictl pull` any OCI v2 registry (GHCR, redhat.io, private); `run --image` | `bash scripts/container-separate-repos-phase10-gate.sh` |

Advance `state.json` → next phase only when the current phase gate passes.

## Syntax policy

- **`def` only** in package repos — no `proc`
- Trusted FFI: **`extern def`** in `std/runtime/seam.li` only (+ dev copy in `li-container/src/seam.li`)

## Do not

- Fold `li-oci` into `li-container`
- Put syscall code in package repos or librebase product trees
- Add `extern def` outside `std/runtime/seam.li`
- Treat `packages/licontainers/` as long-term home (thin re-export or delete after P6)
- Push git directly to GitHub (GitLab primary; mirror via scripts)

## K8s worker

```bash
cd li-cursor-agents
export KUBECONFIG=~/.kube/config-homelab
export GITLAB_TOKEN=... CURSOR_API_KEY=...
bash scripts/setup-engine-k8s-container-separate-repos.sh
kubectl -n li-swarm logs -f deploy/li-container-separate-repos
```

## Completion gate

```bash
bash scripts/container-separate-repos-completion-gate.sh
```
