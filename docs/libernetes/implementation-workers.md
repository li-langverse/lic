# libernetes goal-directed K8s workers

Homelab **engine** cluster runs four parallel Cursor agents until each track's completion gate passes.

## Deployments

| Deployment | Branch | Goal file |
|------------|--------|-----------|
| `li-libernetes-platform` | `cursor/libernetes-platform` | `data/goal-directed-sprints/libernetes-platform.md` |
| `li-libernetes-licontainers` | `cursor/libernetes-licontainers` | `data/goal-directed-sprints/libernetes-licontainers.md` |
| `li-libernetes-livm` | `cursor/libernetes-livm` | `data/goal-directed-sprints/libernetes-livm.md` |
| `li-libernetes-control` | `cursor/libernetes-control` | `data/goal-directed-sprints/libernetes-control.md` |

Manifests: `li-cursor-agents-clone/deploy/k8s/engine/`. Setup: `scripts/setup-engine-k8s-libernetes-all.sh`.

## Wave progression

| Wave | Status on main | Active gate |
|------|----------------|-------------|
| 0–2 | **Merged** | wave0–2 gates in completion script |
| 3 | **In progress** (K8s runners) | `check-libernetes-*-wave3-gate.sh` |
| 4–6 | Scripts present; unwired | Enable after prior wave merges |

To advance: merge track PR → add `waveN+1-gate.sh` to `check-libernetes-*-gate.sh` → restart worker Deployment.

## ConfigMap essentials

```yaml
LI_PROOF_EXPLORER_ALWAYS_ON: "1"
LI_PROOF_EXPLORER_EXIT_ON_COMPLETE: "1"
LI_PROOF_EXPLORER_PHASE_HANDOFF: "0"
LI_PROOF_EXPLORER_GOAL_FILE: "data/goal-directed-sprints/libernetes-platform.md"
LI_PROOF_EXPLORER_BRANCH: "cursor/libernetes-platform"
LI_PROOF_EXPLORER_LIC_ROOT: "/workspace/lic"
LI_PROOF_EXPLORER_AGENT: "code_implementer"
LI_SKIP_IMPLEMENTER_PREFLIGHT_GATE: "1"
LI_SWARM_EXTERNAL: "1"
```

## Distributed workloads

See [distributed-workloads.md](distributed-workloads.md). Waves 3–6 implement single-node stack → multi-node join → scheduler dispatch → benchmarks.
