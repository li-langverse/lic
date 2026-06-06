#!/usr/bin/env python3
"""Rewrite docs/ markdown links for MkDocs --strict (lic#403) and HTML hygiene (lic#404)."""
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import quote

REPO = Path(__file__).resolve().parents[1]
DOCS = REPO / "docs"
GITHUB_LIC = "https://github.com/li-langverse/lic/blob/main"
GITHUB_AGENTS = "https://github.com/li-langverse/li-cursor-agents/blob/main"
GITHUB_RESEARCH = "https://github.com/li-langverse/research-findings/blob/main"

LINK_RE = re.compile(r"(\[[^\]]*\]\()([^)#]+)(\#[^)]*)?(\))")

# Applied only under docs/superpowers/plans/
PLANS_SUBS: list[tuple[str, str]] = [
    ("](../ecosystem/", "](../../ecosystem/"),
    ("](../verification/", "](../../verification/"),
    ("](../compiler/", "](../../compiler/"),
    ("](../contributing/", "](../../contributing/"),
    ("](../language/", "](../../language/"),
    ("](docs/architecture/", "](../../architecture/"),
    ("](docs/verification/", "](../../verification/"),
    ("](docs/semantics/", "](../../semantics/"),
    ("](docs/superpowers/specs/", "](../specs/"),
    ("](docs/superpowers/plans/", "]("),
    ("](docs/ecosystem/", "](../../ecosystem/"),
    ("](docs/guide/", "](../../guide/"),
    ("](docs/language/", "](../../language/"),
    ("](docs/compiler/", "](../../compiler/"),
    ("](benchmarks/harness/", f"]({GITHUB_LIC}/benchmarks/harness/"),
    ("](benchmarks/results/", f"]({GITHUB_LIC}/benchmarks/results/"),
]

# Manual overrides for targets that need a specific destination.
EXACT: dict[str, str] = {
    "../../handbook/README.md": "../../language/overview.md",
    "../../proof-database/DISCREPANCIES.md": "../verification/proof-database/DISCREPANCIES.md",
    "../superpowers/specs/2026-05-16-li-math-linalg-surface.md": "../../superpowers/specs/2026-05-16-li-math-linalg-surface.md",
    "../verification/provability-gaps.md": "../verification/provability-gaps.md",
    "../lic/docs/game-dev/PH-ML-GPU-battle-plan.md": "../../game-dev/PH-ML-GPU-battle-plan.md",
    "./2026-05-25-md-r2-neighbor-list-gap.md": "../2026-05-25-md-r2-neighbor-list-gap.md",
    "numerics/2026-05-25-md-r2-neighbor-list-gap.md": "../2026-05-25-md-r2-neighbor-list-gap.md",
    "../release-notes/2026-05-25-bench-fill-wp3-pde-robo-am.md": "../../release-notes/2026-05-25-bench-fill-wp3-pde-robo-am.md",
    "../release-notes/2026-05-28-bench-mean-std-timing.md": "../../release-notes/2026-05-28-bench-mean-std-timing.md",
    "proof-database/entries/README.md": "proof-database/entries/README.md",
}


def github_blob(path: Path) -> str:
    rel = path.relative_to(REPO).as_posix()
    return f"{GITHUB_LIC}/{quote(rel, safe='/')}"


def github_external(path: Path) -> str | None:
    parts = path.parts
    if "li-cursor-agents" in parts:
        idx = parts.index("li-cursor-agents")
        tail = "/".join(parts[idx + 1 :])
        return f"{GITHUB_AGENTS}/{quote(tail, safe='/')}"
    if "research-findings" in parts:
        idx = parts.index("research-findings")
        tail = "/".join(parts[idx + 1 :])
        return f"{GITHUB_RESEARCH}/{quote(tail, safe='/')}"
    return None


def rel_from(source: Path, target: Path) -> str:
    return Path(
        Path(*([".."] * len(source.parent.relative_to(DOCS).parts))),
        *target.relative_to(DOCS).parts,
    ).as_posix()


def resolve_target(source: Path, raw: str) -> str:
    if raw in EXACT:
        return EXACT[raw]

    anchor = ""
    path_part = raw
    if "#" in raw:
        path_part, anchor = raw.split("#", 1)
        anchor = f"#{anchor}"

    if not path_part or path_part.startswith(("http://", "https://", "mailto:")):
        return raw

    resolved = (source.parent / path_part).resolve()

    # Prefer an in-docs markdown target when one exists.
    if resolved.suffix == ".md" and resolved.is_file() and DOCS in resolved.parents:
        return rel_from(source, resolved) + anchor

    # Walk up to find docs/ sibling (e.g. ../../verification from testing/).
    candidate = resolved
    for _ in range(6):
        doc_md = DOCS / candidate.name if candidate.suffix == ".md" else None
        if doc_md and doc_md.is_file():
            rel_doc = DOCS / candidate.relative_to(DOCS) if DOCS in candidate.parents else doc_md
            if rel_doc.is_file():
                return rel_from(source, rel_doc) + anchor
        if candidate.suffix == ".md":
            alt = DOCS / Path(*candidate.parts[candidate.parts.index("docs") + 1 :]) if "docs" in candidate.parts else None
            if alt and alt.is_file():
                return rel_from(source, alt) + anchor
        parent = candidate.parent
        if parent == candidate:
            break
        candidate = parent

    # Shorter relative path into docs/ when file exists.
    if path_part.endswith(".md"):
        name = Path(path_part).name
        for hit in DOCS.rglob(name):
            try:
                return rel_from(source, hit) + anchor
            except ValueError:
                continue

    if REPO in resolved.parents or resolved.is_relative_to(REPO):
        return github_blob(resolved) + anchor

    external = github_external(resolved)
    if external:
        return external + anchor

    return raw


def rewrite_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text
    rel = path.relative_to(DOCS)
    if rel.parts[:2] == ("superpowers", "plans"):
        for old, new in PLANS_SUBS:
            text = text.replace(old, new)

    def fix_link(match: re.Match[str]) -> str:
        prefix, target, frag, suffix = match.group(1), match.group(2), match.group(3) or "", match.group(4)
        combined = target + frag
        if combined.startswith(("http://", "https://", "mailto:", "#")):
            return match.group(0)
        new_target = resolve_target(path, combined)
        return f"{prefix}{new_target}{suffix}"

    text = LINK_RE.sub(fix_link, text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    for md in sorted(DOCS.rglob("*.md")):
        if rewrite_file(md):
            changed += 1
            print(f"updated {md.relative_to(REPO)}")
    print(f"fix-docs-mkdocs-links: {changed} file(s) updated")


if __name__ == "__main__":
    main()
    sys.exit(0)
