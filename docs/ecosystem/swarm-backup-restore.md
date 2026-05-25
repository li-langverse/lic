# Swarm state backup and restore (WP-M0)

<!-- DOC-ecosystem-swarm-backup-restore -->

**Audience:** Operators migrating from `lic` systemd plan loops to the `li-cursor-agents` goal-directed swarm.

| | |
|--|--|
| **Script** | [`scripts/backup-swarm-state.sh`](../../scripts/backup-swarm-state.sh) |
| **Default output** | `~/Documents/Cursor/backups/swarm-YYYYMMDD/` |
| **Manifest** | `manifest.json` (timestamp, git SHAs, tar paths, systemd unit list) |

Run **before** disabling plan loops or merging control-plane branches (WP-M4 / WP-M5).

## What is captured

| Artifact | Location in backup |
|----------|-------------------|
| Git branch + SHA | `git/*.txt` and `manifest.json` → `repos` for `lic`, `li-cursor-agents`; `benchmarks` noted as a path inside `lic` |
| Plan-loop runtime data | `tar/swarm-runtime-data.tar.gz` — `lic/data/*-plan-loop`, `sim-plan-loop`, `security-research-loop`, `goal-directed-agents`, `swarm-gap-registry`; `li-cursor-agents/data/control-plane`; worktree copies under `lic-worktrees/*` and `lic-studio-ui` when present |
| systemd units | `systemd/li-*.service` copies from `~/.config/systemd/user/` |

## What is excluded (by design)

| Item | Reason |
|------|--------|
| `.env` / `*.env` | Secrets — **copy manually** after restore |
| Git objects / full repos | Use normal `git checkout` at recorded SHAs |
| GitHub org mirrors | See [org-backup.md](org-backup.md) |

### Manual credential copy

```bash
# After restore, on the target machine:
install -m 600 -D ~/Documents/Cursor/.env ~/Documents/Cursor/.env
# Or set LI_CURSOR_ENV_FILE to your env path before starting agents systemd.
```

Never commit `.env` or place it inside the backup tar.

## Run backup

```bash
cd /path/to/li-langverse/lic
chmod +x scripts/backup-swarm-state.sh
./scripts/backup-swarm-state.sh
```

Optional overrides:

```bash
BACKUP_ROOT=~/Documents/Cursor/backups \
LI_CURSOR_AGENTS_ROOT=~/Documents/Cursor/li-langverse/li-cursor-agents \
./scripts/backup-swarm-state.sh
```

Inspect result:

```bash
BACKUP=~/Documents/Cursor/backups/swarm-$(date -u +%Y%m%d)
jq . "$BACKUP/manifest.json"
tar -tzf "$BACKUP/tar/swarm-runtime-data.tar.gz" | head
```

## Restore procedure

1. **Checkout code** at manifest SHAs:
   ```bash
   jq -r '.repos[] | select(.name=="lic") | "\(.branch) \(.sha)"' "$BACKUP/manifest.json"
   cd /path/to/lic && git fetch && git checkout <sha>
   cd /path/to/li-cursor-agents && git checkout <sha>
   ```

2. **Extract runtime data** (paths in tar are absolute-from-root style under `/`):
   ```bash
   sudo tar -xzf "$BACKUP/tar/swarm-runtime-data.tar.gz" -C /
   ```
   On a different machine, extract to the same absolute paths listed in `manifest.json` (`lic_root`, `agents_root`), or extract selectively:
   ```bash
   tar -xzf "$BACKUP/tar/swarm-runtime-data.tar.gz" -C /tmp/swarm-restore --strip-components=0
   # then rsync each directory to lic/data/... and agents/data/control-plane
   ```

3. **Restore systemd units**:
   ```bash
   cp -a "$BACKUP/systemd/"li-*.service ~/.config/systemd/user/
   systemctl --user daemon-reload
   ```

4. **Copy `.env` manually** (see above).

5. **Re-enable loops only if rolling back migration** — otherwise prefer [`install-agents-swarm-systemd.sh`](../../../li-cursor-agents/scripts/install-agents-swarm-systemd.sh) in WP-M5.

## Related

- [swarm-ops-status.md](swarm-ops-status.md) — live loop status
- [org-backup.md](org-backup.md) — GitHub org mirrors (separate from this snapshot)
- Goal-directed migration plan: `goal_directed_swarm_unified` (Cursor plans)
