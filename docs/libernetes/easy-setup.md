# libernetes easy setup

## Single-node homelab

```bash
libernetes init --profile homelab --bind-address 0.0.0.0
export KUBECONFIG=/etc/libernetes/admin.conf
libernetes doctor
```

## Add heterogeneous worker

```bash
libernetes worker join https://cp.homelab.lan:6443 \
  --token <token> \
  --profile auto
```

Auto-detected labels: `libernetes.io/arch`, `libernetes.io/kvm`, `libernetes.io/container`, `libernetes.io/gpu`.

## Profiles

| Profile | Use |
|---------|-----|
| `homelab` | single node, embedded etcd |
| `ha` | 3+ control plane nodes |
| `auto` | join: detect all capabilities |

## Verify

```bash
libernetes doctor   # CRI, livm, CNI, etcd, apiserver
kubectl get nodes -o wide
```
