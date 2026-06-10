# libernetes benchmarks (Wave 6)

Performance gates for distributed libernetes vs k3s on homelab hardware.

## Tiers

| Tier | Suite | Package |
|------|-------|---------|
| CRI | pull/start/stop | **licontainers** `li-tests/bench/cri_ops.li` |
| VM | cold boot / snapshot | **livm** `li-tests/bench/vm_boot.li` |
| CP | apiserver LIST, pod churn | `scripts/bench-libernetes-pod-churn-gate.sh` |
| E2E | cross-node workload | kubelet `li-tests/e2e/distributed_workload.li` |

## Gate

```bash
bash scripts/bench-libernetes-pod-churn-gate.sh
```

Target (post Wave 6): ≥1.5× k3s pod churn on engine node profile.
