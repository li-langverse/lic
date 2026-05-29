# Execute PH-ML GPU work package

Use when landing a single WP from [PH-ML-GPU-battle-plan.md](../../../docs/game-dev/PH-ML-GPU-battle-plan.md).

## Preconditions

1. Read battle plan §5 row for your WP (Depends, Proof gate, Size).
2. Read [PH-ML-GPU-execution-tracker.md](../../../docs/game-dev/PH-ML-GPU-execution-tracker.md) — confirm no file-lock conflict.
3. Branch: `feat/wp-<id>-<short-slug>` from `main` or latest wave branch.

## Agent template

```markdown
## WP-<ID>: <title>

**Track:** PH-ML | PH-HW | G-gpu | RL | BENCH | DOC
**Depends:** <list>
**Proof gate:** <smoke or bench id>

### Plan (≤5 bullets)
- …

### Files (minimal)
- packages/li-ml/… OR packages/lig/… OR compiler/…

### Verify
./scripts/build.sh
lic check <smoke paths>

### Honesty
- No GPU perf / PyTorch parity claims unless Tier-3 CSV exists.
```

## Implementation rules

- Use **`def`**, not `proc`, in all new Li surface code.
- Pure Li for ML logic; `import lig` only at runtime boundary (matmul bridge, device probe).
- Contracts on public `def`s where the package already uses them.
- Release note + CHANGELOG Unreleased entry when behavior is user-visible.

## Done checklist

- [ ] Proof gate green (`lic check` or named bench)
- [ ] Tracker row updated (`state`, `branch`, `verify`, `blocker`)
- [ ] No scope creep outside WP file list
- [ ] Commit message: `feat(PH-ML): WP-<ID> <short description>`
