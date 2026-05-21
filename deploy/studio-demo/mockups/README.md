# Studio UI mockups — not stored in git

**Canonical design surface:** [../index.html](../index.html) (HTML/CSS/JS prototype).

PNG concept art is **not** committed to `lic`. Regenerate locally:

```bash
# Interactive (best — live agent dock, all tabs)
./scripts/open-studio-design-preview.sh

# Static PNG gallery → .artifacts/studio-mockups/ (gitignored)
./scripts/capture-studio-mockup-screenshots.sh
./scripts/open-studio-design-preview.sh --gallery
```

**Product repo target:** `studio-app/demo/` — same rule: no binary mockups in git unless release assets.

Docs: [planned-ui-mockups.md](../../../docs/game-dev/planned-ui-mockups.md)
