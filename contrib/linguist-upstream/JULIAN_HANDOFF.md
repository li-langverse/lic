# Julian handoff — GitHub Linguist PR (WP7)

**Pretend-user / no agent committer:** Only **Julian** may commit, push, and open the PR on `github-linguist/linguist`. Agents prepare lic docs and `contrib/linguist-upstream/`; they **must not** appear as author on the upstream PR and **must not** push to any linguist remote.

## Preconditions

- [ ] WP1 merged: [`contrib/li-grammar/`](../../contrib/li-grammar/) on `lic` `main`; grammar repo live (not TBD)
- [ ] WP2 merged: [`contrib/linguist-samples/`](../../contrib/linguist-samples/) + [`SAMPLES_LICENSES.md`](../../contrib/linguist-samples/SAMPLES_LICENSES.md)
- [ ] WP3: usage bar met **or** maintainer exception — [usage evidence](../../docs/ecosystem/github-linguist-usage-evidence.md)
- [ ] WP6: patch applied per [PATCH_INSTRUCTIONS.md](./PATCH_INSTRUCTIONS.md); `bundle exec rake test` green locally

## Checklist

### Fork and branch

- [ ] Fork `https://github.com/github-linguist/linguist` to `https://github.com/<JULIAN_GITHUB_USER>/linguist`
- [ ] `git clone` your fork; `git remote add upstream https://github.com/github-linguist/linguist.git`
- [ ] `git fetch upstream && git checkout -b add-li-language upstream/main`

### Git identity (Julian only)

```bash
git config user.name "Julian <Legal Name>"
git config user.email "<julian-email@domain>"
```

Verify before commit:

```bash
git var GIT_COMMITTER_IDENT
git var GIT_AUTHOR_IDENT
```

### Apply patch

- [ ] Follow [PATCH_INSTRUCTIONS.md](./PATCH_INSTRUCTIONS.md) (grammar, `languages.yml`, samples, optional heuristics, `script/update-ids`, tests)
- [ ] **Do not** submodule placeholder `https://github.com/li-langverse/li-grammar` until repo exists

### Commit and push

- [ ] Single logical commit (or squash) authored by Julian
- [ ] `git push -u origin add-li-language`

### Open PR

```bash
gh pr create \
  --repo github-linguist/linguist \
  --head <JULIAN_GITHUB_USER>:add-li-language \
  --base main \
  --title "Add Li language" \
  --body "$(cat <<'EOF'
## Summary
Adds Li (`.li`) with TextMate grammar, samples from li-langverse/lic, and interpreter `lic`.

## Usage evidence
- Global: <paste GitHub search URL + count — extension:li NOT is:fork>
- Li syntax: <paste URL e.g. extension:li "requires" NOT is:fork>
- Distribution: <note manual spot-check; -user: filters if needed>

## Licenses
- Grammar: MIT — https://github.com/li-langverse/li-grammar (link LICENSE)
- Samples: MIT — provenance table from lic commit <SHA> (see SAMPLES_LICENSES.md)

## Samples
Written for Linguist / copied from lic tests and examples; MIT; not hello-world tutorials.

EOF
)"
```

Fill template bullets — Linguist **will not review** if the PR template is empty ([CONTRIBUTING](https://github.com/github-linguist/linguist/blob/main/CONTRIBUTING.md)).

### After open

- [ ] Monitor CI on the PR; fix grammar/vendor issues on **your fork** only
- [ ] Respond to maintainer requests (heuristics, usage `-user:` filters)
- [ ] Do **not** merge your own PR unless org policy explicitly allows

## PR template bullets (required)

| Bullet | Content |
|--------|---------|
| Search links | `extension:li NOT is:fork` + Li-specific query with counts |
| Licenses | Grammar MIT + per-sample SPDX from `SAMPLES_LICENSES.md` |
| Distribution | Honest note if org slice still growing; no false “threshold met” |
| Heuristics | Mention if `heuristics-li.fragment.yml` applied and why (collision) |
| Downstream | After merge, GitHub.com picks up on Linguist release cadence (days/weeks) |

## Agent stop line (repeat)

Agents stop at lic merge of WP4/WP6 docs. **WP7 is human-only.**

## Related

- [Playbook](../../docs/ecosystem/github-linguist.md)
- [Usage evidence](../../docs/ecosystem/github-linguist-usage-evidence.md)
