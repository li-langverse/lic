# Moved → `li-world-studio` repo

**Studio demo, mockups, and demo video** belong in the **product repo**, not `lic`:

**Target:** [github.com/li-langverse/li-world-studio](https://github.com/li-langverse/li-world-studio)  
**Path after split:** `li-world-studio/demo/` (was `lic/deploy/studio-demo/`)

## Bootstrap locally

```bash
cd lic
./scripts/bootstrap-li-world-studio-repo.sh ../li-world-studio
cd ../li-world-studio
python3 -m http.server 8765 --directory demo
# http://localhost:8765/preview.html
```

## Why

| Repo | Role |
|------|------|
| **lic** | Compiler, std, composable gates, monorepo integration |
| **li-studio** | `studio` package (shell API) |
| **li-studio-ai** | `studio.ai` package |
| **li-world-studio** | App + HTML demo + UX mocks + video |

See [docs/ecosystem/li-studio-repos.md](../../docs/ecosystem/li-studio-repos.md).

**Until the GitHub repo exists:** files remain here on `feat/agent-first-gui` for convenience.
