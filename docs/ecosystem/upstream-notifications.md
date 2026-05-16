# Upstream release notifications (8-sync)

When **`lic`**, **`lit`**, or **`lip`** releases, dependent repos get a GitHub **issue** and/or **`repository_dispatch`**.

## Wiring

| Repo | On release | Notifies |
|------|------------|----------|
| **lic** | `notify-downstream.yml` | repos in `.github/li-downstream-repos.txt` |
| **lit** | `notify-downstream-lit.yml` | **lip** (and more via list later) |
| each package | `ecosystem-upstream.yml` | opens tracking issue in that repo |

## Action needed from you (one-time)

1. **Secret on `li-langverse/lic`:** `LI_DOWNSTREAM_DISPATCH_TOKEN` — fine-grained PAT scoped to `li-langverse`, with permission to dispatch to **lip**, **lit**, and official packages.
2. **Optional org app:** [Renovate](https://github.com/apps/renovate) on `li-langverse` for auto-PRs on `lic_version` in `li-toolchain.toml`.
3. **Label:** create `ecosystem-upstream` on repos (or issues will be created without label).
4. **Push** updated workflows to **lic**, **lip**, **lit** on GitHub.

## Test

After push, run **notify-downstream** workflow_dispatch on **lic** with a test version, or publish a patch release — **lip** should run **ecosystem-upstream** and open an issue.
