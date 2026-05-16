# Org backup (li-langverse experiment)

<!-- DOC-ecosystem-org-backup -->

**Audience:** Maintainers running the agent-open **`li-langverse`** org experiment.

**Live org:** [`li-langverse`](https://github.com/li-langverse) (public repos)  
**Backup org:** [`li-langverse-backup`](https://github.com/li-langverse-backup) (private mirrors, auto-created)

## Credentials (agents must not use)

| File | Purpose |
|------|---------|
| `coding-projects/.env.github` | Agent PAT — **do not** use for backup |
| `coding-projects/.env.github.backup` | `BACKUP_GH_TOKEN`, `BACKUP_OWNER=li-langverse-backup` |

Copy [`scripts/env.github.backup.example`](../../scripts/env.github.backup.example), `chmod 600`.

Agents **must not** run `backup-li-langverse-org.sh`, `export-li-langverse-metadata.sh`, or read `.env.github.backup`.

## Run backup

```bash
cd /path/to/li
./scripts/backup-li-langverse-org.sh
./scripts/export-li-langverse-metadata.sh
```

- Discovers all repos in `li-langverse`
- Bare-mirrors to `~/Documents/li-langverse-backup/mirrors/li-langverse/<name>.git`
- Creates missing **`li-langverse-backup/<name>`** private repos and `git push --mirror`
- Writes `~/Documents/li-langverse-backup/LAST_SUCCESS.txt`

## Daily cron (optional)

```bash
0 3 * * * /path/to/li/scripts/backup-li-langverse-org.sh && /path/to/li/scripts/export-li-langverse-metadata.sh
```

## Recovery (live org damaged)

1. Revoke agent PAT in `.env.github`; rotate all Actions secrets on live repos.
2. Compare `LAST_SUCCESS.txt` to `git ls-remote` on live.
3. From bare mirror: `gh repo create li-langverse/<name> --public` then `git push --mirror` from `mirrors/li-langverse/<name>.git`.
4. Re-apply branch protection from `metadata/*/repo-*-rulesets.json`.
5. Re-create downstream secrets per [upstream-notifications.md](upstream-notifications.md).

## Scripts

| Script | Role |
|--------|------|
| [`scripts/backup-li-langverse-org.sh`](../../scripts/backup-li-langverse-org.sh) | Mirror + auto-create private repos on backup org |
| [`scripts/export-li-langverse-metadata.sh`](../../scripts/export-li-langverse-metadata.sh) | JSON snapshots under `metadata/` |
| [`scripts/with-github-backup-env.sh`](../../scripts/with-github-backup-env.sh) | Loads `.env.github.backup` only |

## Related

- [org-push.md](org-push.md) — push lic/lip/lit to live org
- [agent-coordination.md](agent-coordination.md) — multi-agent rules
