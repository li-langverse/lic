# Package gap register (libernetes Wave 0)

| Package | Status | Needed for |
|---------|--------|------------|
| li-etcd | stub | apiserver persistence |
| li-grpc | stub | CRI, webhooks |
| li-watch | stub | informers |
| li-workqueue | stub | controllers |
| li-oci | published (mirror) | OCI image format, pull/store |
| li-container | published (mirror) | bundle, state, backends |
| li-container-run | published (mirror) | lirun lifecycle |
| li-containerd | scaffold | container daemon |
| li-container-cli | scaffold | ctr-style CLI |
| li-container-cri | scaffold | CRI shim |
| li-kvm | missing | livm Linux backend |
| licontainers | deprecated shim | use li-oci + li-container + li-container-run |
| livm | wave2 stub | VMs |
| li-libernetes-core | scaffold | shared types |

Primary repos: GitLab `gitlab.lilangverse.xyz/li-langverse/{li-oci,li-container,li-container-run}`.  
GitHub mirrors via `./scripts/push-container-package-mirrors.sh`.

Update this file as stubs land.
