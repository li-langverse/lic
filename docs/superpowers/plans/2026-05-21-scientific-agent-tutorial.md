# Build and Verify a Small Scientific Li Program Tutorial Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write a first tutorial that helps new Li users, scientific/HPC developers, and repo automation authors build one small verified numerical program without needing to understand the whole ecosystem first.

**Architecture:** The tutorial is a single guided path in `docs/guide/` with short chapters, runnable examples, and links out to deeper references only when the reader needs them. It starts as a friendly first program, then reveals Li's contract, proof, testing, benchmark, and agent workflow one step at a time.

**Tech Stack:** Markdown for MkDocs Material, `nim` fences for Li source, `bash` fences for terminal commands, `toml` fences for manifests, and existing Li docs styling from `mkdocs.yml` and `docs/stylesheets/extra.css`.

---

## Reader promise

The tutorial should feel like a calm lab partner: clear, occasionally witty, and honest about what Li can and cannot prove today. The voice should be humble. Li can be ambitious without sounding like it has solved physics before coffee.

The reader should finish with:

1. A working mental model of `def`, `requires`, `ensures`, and `decreases`.
2. One small scientific calculation that reads like prose.
3. A clear distinction between `lic check` for fast feedback and `lic build` for the real proof gate.
4. A practical path from local code to tests, benchmark evidence, branch, PR, and release notes.

## Audience blend

| Audience | What they need | How the tutorial serves them |
|----------|----------------|-------------------------------|
| New Li user | First runnable program and low jargon | Starts with a tiny numerical function before naming the full ecosystem |
| Agent author | Safe cross-repo workflow | Includes branch, PR-only, release-note, and gate checkpoints |
| Scientific/HPC developer | Proof and performance credibility | Shows contracts first, then points benchmark claims to measured evidence |

## Tone rules

- Prefer short sentences with one idea each.
- Explain why before how when a concept changes the reader's habits.
- Use light humor sparingly. A good joke lowers the ladder; it does not kick the reader off it.
- Avoid victory-lap prose. Say what Li checks, what is still maturing, and where the reader can verify the claim.
- Keep every code sample copy-pasteable. No elided commands, no mystery files.

## Code block style

The user reference is a polished custom-code article screenshot. Match the spirit in the docs site with real, copyable blocks rather than images of code.

Required rules:

1. Every fenced block must have a language tag.
2. Li examples use `nim`, matching the existing docs convention for Li surface syntax.
3. Shell commands use `bash`.
4. Manifest examples use `toml`.
5. Structured diagnostics use `json`.
6. Keep blocks short enough to scan, then explain the important lines underneath.
7. Prefer one complete block over several fragments when the reader needs to copy it.
8. Rely on MkDocs Material features already enabled in `mkdocs.yml`: syntax highlighting, copy buttons, annotations, and the JetBrains Mono code font.

Example Li block:

```nim
def kinetic_energy(mass: float, speed: float) -> float
  requires mass >= 0.0
  requires speed >= 0.0
  ensures result >= 0.0
  decreases 0
=
  return 0.5 * mass * speed * speed
```

Example command block:

```bash
./build/compiler/lic/lic check docs/examples/kinetic_energy.li
./build/compiler/lic/lic build docs/examples/kinetic_energy.li -o kinetic-energy --release
```

Example manifest block:

```toml
[tutorial]
name = "kinetic-energy"
goal = "show a small scientific function with contracts"
```

## Proposed tutorial file

Create `docs/guide/build-and-verify-scientific-program.md`.

Add it to `mkdocs.yml` under `Guide` after `Hello world` and before `Install tools`, so beginners see it early.

## Tutorial outline

### 1. What this tutorial is for

Open with one sentence: build a tiny scientific Li program, check it, prove the important promises, test it, and learn where performance evidence belongs.

Link to:

- `docs/guide/getting-started-tools.md`
- `docs/guide/hello-world.md`
- `docs/ecosystem/strict-by-default.md`
- `docs/ecosystem/engineering-standards.md`

### 2. The tiny scientific program

Use kinetic energy or a bounded dot-product-style scalar example. Kinetic energy is best for the first version because the contract is easy to read and nonnegative output is intuitive.

Start with this source:

```nim
def kinetic_energy(mass: float, speed: float) -> float
  requires mass >= 0.0
  requires speed >= 0.0
  ensures result >= 0.0
  decreases 0
=
  return 0.5 * mass * speed * speed
```

Then add a `main` wrapper only after the function is understood.

### 3. Check first, build when it matters

Show `lic check` as the fast loop and `lic build` as the trusted path.

```bash
./build/compiler/lic/lic check docs/examples/kinetic_energy.li
./build/compiler/lic/lic build docs/examples/kinetic_energy.li -o kinetic-energy --release
```

Explain that `lic check` is a friendly linting dog, while `lic build` is the gatekeeper with a clipboard.

### 4. Why the contracts are there

Teach the contract lines as plain promises:

| Line | Reader meaning |
|------|----------------|
| `requires mass >= 0.0` | Do not call this with impossible physical mass |
| `requires speed >= 0.0` | Keep the first example simple; direction is not the lesson |
| `ensures result >= 0.0` | Energy should not come back negative |
| `decreases 0` | This function has no loop, so termination is immediate |

Include one failing example so the reader sees compile-time feedback as help, not punishment.

### 5. Add a test

Use the existing test style from `li-tests/` once the exact fixture path is chosen during implementation. The tutorial should show the test command and expected pass condition.

```bash
./li-tests/run_all.sh
```

If a narrow tutorial-specific command exists by then, prefer it; otherwise explain that the full suite is the honest gate.

### 6. Performance claims go through evidence

Do not claim the tiny example is fast just because it builds with `--release`. Explain that performance claims belong in benchmark rows and dashboard evidence.

Link to:

- `docs/guide/fast-math-and-parallelism.md`
- `docs/benchmarks.md`
- `https://li-langverse.github.io/benchmarks/`

### 7. Agent workflow

End with the minimum safe cross-repo workflow:

```bash
git checkout -b cursor/scientific-tutorial-example-e8f9
git status --short --branch
git add docs/guide/build-and-verify-scientific-program.md mkdocs.yml
git commit -m "docs: add scientific tutorial"
git push -u origin cursor/scientific-tutorial-example-e8f9
```

Then explain PR-only, changelog, release note, functionality/security/performance gates, and why agents stop before merging.

## Implementation tasks

### Task 1: Add the tutorial page skeleton

**Files:**
- Create: `docs/guide/build-and-verify-scientific-program.md`
- Modify: `mkdocs.yml`

- [ ] **Step 1: Create the page with the title, purpose, prerequisites, and reader promise**

Use concise prose and link to existing setup docs instead of duplicating installation content.

- [ ] **Step 2: Add the page to the Guide navigation**

Place it after `Hello world` so it is visible before specialized package or benchmark docs.

- [ ] **Step 3: Commit**

```bash
git add docs/guide/build-and-verify-scientific-program.md mkdocs.yml
git commit -m "docs: add scientific tutorial skeleton"
```

### Task 2: Add the scientific example

**Files:**
- Modify: `docs/guide/build-and-verify-scientific-program.md`
- Create: `docs/examples/kinetic_energy.li` if examples under `docs/examples/` are accepted during implementation

- [ ] **Step 1: Write the Li function using `def` and full contracts**

Use the `kinetic_energy` example from this plan unless implementation finds an existing better example with a passing fixture.

- [ ] **Step 2: Add copy-pasteable check and build commands**

Use `bash` fences and full paths from the repository root.

- [ ] **Step 3: Run the command shown in the tutorial**

The command in the tutorial must be a command that has actually run successfully in the PR.

- [ ] **Step 4: Commit**

```bash
git add docs/guide/build-and-verify-scientific-program.md docs/examples/kinetic_energy.li
git commit -m "docs: add verified scientific tutorial example"
```

### Task 3: Add testing, performance, and agent workflow sections

**Files:**
- Modify: `docs/guide/build-and-verify-scientific-program.md`

- [ ] **Step 1: Add a testing section with an exact command**

Use the narrowest real command available. If the full suite is the only reliable command, use `./li-tests/run_all.sh` and say why.

- [ ] **Step 2: Add a performance section that refuses unsupported speed claims**

Point to benchmarks and explain that evidence beats vibes. Vibes are fine for playlists, not performance tables.

- [ ] **Step 3: Add an agent workflow section**

Cover branch, status, add, commit, push, PR, release notes, and stop-before-merge.

- [ ] **Step 4: Commit**

```bash
git add docs/guide/build-and-verify-scientific-program.md
git commit -m "docs: add tutorial testing and agent workflow"
```

### Task 4: Verify docs quality

**Files:**
- Check: `docs/guide/build-and-verify-scientific-program.md`
- Check: `mkdocs.yml`

- [ ] **Step 1: Search for placeholders**

```bash
python3 - <<'PY'
from pathlib import Path
paths = [
    Path("docs/guide/build-and-verify-scientific-program.md"),
    Path("mkdocs.yml"),
]
needles = ["T" + "BD", "TO" + "DO", "." * 3, "fi" + "ll in", "imple" + "ment later"]
failed = False
for path in paths:
    text = path.read_text()
    for needle in needles:
        if needle in text:
            print(f"{path}: contains {needle}")
            failed = True
raise SystemExit(1 if failed else 0)
PY
```

- [ ] **Step 2: Search for unlabeled fenced code blocks**

```bash
python3 - <<'PY'
from pathlib import Path
path = Path("docs/guide/build-and-verify-scientific-program.md")
bad = []
in_fence = False
for lineno, line in enumerate(path.read_text().splitlines(), 1):
    stripped = line.strip()
    if stripped.startswith("```"):
        if not in_fence and stripped == "```":
            bad.append(lineno)
        in_fence = not in_fence
if bad:
    print(f"{path}: unlabeled opening fences at lines {bad}")
    raise SystemExit(1)
PY
```

- [ ] **Step 3: Run the relevant docs or CI command**

Prefer the repository docs build if available. If the environment lacks optional docs dependencies, run the placeholder and fence checks plus the tutorial's shown `lic` commands, and record the limitation in the PR.

## Scope fence

This plan does not implement new compiler behavior, benchmark kernels, proof rules, package publishing, or agent-kit changes. It only plans a tutorial that teaches existing behavior accurately.
