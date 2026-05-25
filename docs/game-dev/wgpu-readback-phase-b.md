# wgpu readback — phase B checklist (after #288 phase A)

**Status:** Scaffold — `LIG_WGPU_READBACK=0` default; stub returns `0`. wgpu-rs **N/A** this PR.

See [wgpu-readback-path.md](wgpu-readback-path.md). Depends on [PR #288](https://github.com/li-langverse/lic/pull/288).

## Env gate

| Variable | Default | Meaning |
|----------|---------|---------|
| `LIG_WGPU_READBACK` | `0` | `1` opts in; still no-op until wgpu-rs in-tree |

## Verification

```bash
lic check packages/lig/li-tests/smoke/wgpu_readback_stub.li
```
