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

## Wave wiring rule

Each track's **completion gate** (`check-libernetes-{track}-gate.sh`) chains every merged wave gate through the **active** wave:

1. Earlier waves (0ÔÇôNÔêÆ1) must pass ÔÇö workers never idle on a completed wave.
2. The **active** wave gate (`check-libernetes-{track}-waveN-gate.sh`) is the last script in the chain.
3. Later wave scripts (N+1ÔÇô9) ship in-repo but stay **unwired** until wave N passes on the branch.
4. Goal sprint markdown lists **every LB-* phase** for the active wave with checkbox status; workers iterate until all pending phases pass.
5. Runners report `GOAL_INCOMPLETE` while any wired gate fails; `GOAL_COMPLETE` only when the full chain passes.

To advance wave N ÔåÆ N+1: mark wave N phases **DONE** in the sprint file, append `waveN+1-gate.sh` to the completion gate, push the cursor branch, restart the Deployment.

## Wave progression

| Wave | Status | Active gate |
|------|--------|-------------|
| 0ÔÇô2 | **Merged to main** | wave0ÔÇô2 gates in completion script |
| 3 | **DONE** (cursor branches) | `check-libernetes-*-wave3-gate.sh` |
| 4 | **ACTIVE** (K8s runners) | `check-libernetes-*-wave4-gate.sh` |
| 5ÔÇô6 | Scripts present; unwired | Enable after Wave 4 passes |
| 7ÔÇô9 | Self-heal, persistence, dashboard stubs | Enable after Wave 6 passes |

See [cluster-operations.md](cluster-operations.md) for Waves 7ÔÇô9 deliverables.

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

See [distributed-workloads.md](distributed-workloads.md). Waves 3ÔÇô6 implement single-node stack ÔåÆ multi-node join ÔåÆ scheduler dispatch ÔåÆ benchmarks.

## Restart after wiring

```bash
export KUBECONFIG=~/.kube/config-homelab
kubectl -n li-swarm rollout restart deploy/li-libernetes-platform deploy/li-libernetes-licontainers deploy/li-libernetes-livm deploy/li-libernetes-control
kubectl -n li-swarm logs -f deploy/li-libernetes-control --tail=50
```

Workers should report `GOAL_INCOMPLETE` until the active wave gate passes, then `GOAL_COMPLETE`.
