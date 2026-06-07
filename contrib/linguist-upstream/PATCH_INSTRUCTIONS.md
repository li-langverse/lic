# Linguist upstream patch — apply on Julian's fork

Apply on a **local clone of Julian's linguist fork**, not in `lic` CI. Grammar submodule URL must be **final** after WP1 publishes `li-grammar` (replace TBD below).

## Paths (lic → linguist)

| lic (after WP1/2 merge) | linguist fork |
|-------------------------|---------------|
| [`contrib/li-grammar/`](../../contrib/li-grammar/) → published repo | `script/add-grammar` target |
| [`contrib/linguist-samples/Li/`](../../contrib/linguist-samples/Li/) | `samples/Li/` |
| [`languages-li.snippet.yml`](./languages-li.snippet.yml) | merge into `lib/linguist/languages.yml` |
| [`heuristics-li.fragment.yml`](./heuristics-li.fragment.yml) | merge into `lib/linguist/heuristics.yml` (if needed) |

**Placeholder (do not submodule until WP1 branch merged):**

```text
https://github.com/li-langverse/li-grammar   # TBD — replace with release tag URL
```

## One-time setup

```bash
git clone https://github.com/<JULIAN_GITHUB_USER>/linguist.git
cd linguist
git remote add upstream https://github.com/github-linguist/linguist.git
git fetch upstream
git checkout -b add-li-language upstream/main
script/bootstrap
```

## 1. Add grammar

When `li-grammar` exists and LICENSE is on Linguist's [allowed list](https://github.com/github-linguist/linguist/blob/main/vendor/licenses/config.yml):

```bash
script/add-grammar https://github.com/li-langverse/li-grammar
# If replacing a draft vendor path:
# script/add-grammar --replace Li https://github.com/li-langverse/li-grammar
```

Do **not** run `add-grammar` with the placeholder URL while the repo is empty or TBD.

## 2. Add `languages.yml` entry

1. Open `lib/linguist/languages.yml`.
2. Insert contents of [`languages-li.snippet.yml`](./languages-li.snippet.yml) in alphabetical order (keep `.li` as the only extension; primary extension first).
3. Do not hand-edit `language_id` — step 5 generates it.

## 3. Copy samples (WP2)

From lic checkout at the commit recorded in `contrib/linguist-samples/SAMPLES_LICENSES.md`:

```bash
LIC_ROOT=/path/to/lic
LINGUIST_ROOT=/path/to/linguist
mkdir -p "$LINGUIST_ROOT/samples/Li"
rsync -a "$LIC_ROOT/contrib/linguist-samples/Li/" "$LINGUIST_ROOT/samples/Li/"
```

Verify ≥2 samples if another language already claims `.li` (currently unlisted — still keep 10 representative files).

```bash
cd "$LINGUIST_ROOT"
bundle exec rake samples
```

## 4. Heuristics (optional)

If reviewers report LemonOS / other `.li` false positives:

1. Open `lib/linguist/heuristics.yml`.
2. Merge [`heuristics-li.fragment.yml`](./heuristics-li.fragment.yml) under `.li:` (preserve existing keys if any).
3. Re-run tests (step 6).

## 5. Update language IDs

```bash
script/update-ids
git add lib/linguist/languages.yml
```

Confirm `Li` gained a numeric `language_id` in `languages.yml`.

## 6. Test

```bash
bundle exec rake test
# Optional classifier check if heuristics changed:
bundle exec script/cross-validation --test
```

## 7. Commit on fork (Julian identity)

```bash
git status
git add lib/linguist/languages.yml lib/linguist/heuristics.yml samples/Li vendor/grammars
git commit -m "Add Li language (.li)"
```

Use Julian's `user.name` / `user.email` — see [JULIAN_HANDOFF.md](./JULIAN_HANDOFF.md). **Agents must not run this commit.**

## 8. Push and open PR

```bash
git push -u origin add-li-language
gh pr create --repo github-linguist/linguist --head <JULIAN_GITHUB_USER>:add-li-language \
  --title "Add Li language" \
  --body-file /path/to/pr-body.md
```

PR body must include usage search URLs from [github-linguist-usage-evidence.md](../../docs/ecosystem/github-linguist-usage-evidence.md) and sample license table from `SAMPLES_LICENSES.md`.
