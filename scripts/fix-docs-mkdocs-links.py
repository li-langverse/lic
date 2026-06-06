#!/usr/bin/env python3
"""Rewrite docs/ markdown links so MkDocs builds HTML without raw .md hrefs."""
from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DOCS = REPO / "docs"
GITHUB = "https://github.com/li-langverse/lic/blob/main"

# Global replacements (old, new) applied to all docs/**/*.md
GLOBAL_SUBS: list[tuple[str, str]] = [
    ("../../SECURITY.md", f"{GITHUB}/SECURITY.md"),
    ("../../proof-database/DISCREPANCIES.md", "proof-database/DISCREPANCIES.md"),
    ("../../proof-db/README.md", f"{GITHUB}/proof-db/README.md"),
    ("../../proof-db/reporter.md", f"{GITHUB}/proof-db/reporter.md"),
    ("../../ecosystem/lip.md", "https://github.com/li-langverse/lip/blob/main/docs/lip.md"),
    ("../../ecosystem/lit.md", "https://github.com/li-langverse/lit/blob/main/docs/lit.md"),
    ("../../ecosystem/registry.md", "https://github.com/li-langverse/lip/blob/main/docs/registry.md"),
    ("../../verification/packages.md", f"{GITHUB}/docs/verification/packages.md"),
    ("../../handbook/README.md", "../../language/overview.md"),
    ("../benchmarks/competitive-engines-plan.md", f"{GITHUB}/docs/benchmarks/competitive-engines-plan.md"),
    ("../game-dev/competitive-bioengineering-plan.md", f"{GITHUB}/docs/game-dev/competitive-bioengineering-plan.md"),
    ("../game-dev/plans/li-native-gui-plan.md", f"{GITHUB}/docs/game-dev/plans/li-native-gui-plan.md"),
    ("../superpowers/specs/2026-05-16-li-math-linalg-surface.md", "../../superpowers/specs/2026-05-16-li-math-linalg-surface.md"),
    ("../verification/provability-gaps.md", "../../verification/provability-gaps.md"),
    ("sim-packages-algorithm-plan.md", f"{GITHUB}/docs/ecosystem/sim-packages-algorithm-plan.md"),
    ("../../contrib/linguist-samples/SAMPLES_LICENSES.md", f"{GITHUB}/contrib/linguist-samples/SAMPLES_LICENSES.md"),
    ("../../contrib/linguist-upstream/PATCH_INSTRUCTIONS.md", f"{GITHUB}/contrib/linguist-upstream/PATCH_INSTRUCTIONS.md"),
    ("../../contrib/li-grammar/README.md", f"{GITHUB}/contrib/li-grammar/README.md"),
    ("../../contrib/linguist-samples/README.md", f"{GITHUB}/contrib/linguist-samples/README.md"),
    ("../../contrib/linguist-upstream/JULIAN_HANDOFF.md", f"{GITHUB}/contrib/linguist-upstream/JULIAN_HANDOFF.md"),
    (
        "../../../../research-findings/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/README.md",
        "https://github.com/li-langverse/research-findings/blob/main/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/README.md",
    ),
    (
        "../../../../research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/README.md",
        "https://github.com/li-langverse/research-findings/blob/main/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/README.md",
    ),
    ("../../.cursor/rules/li-agent-scope-studio-sim.mdc", f"{GITHUB}/.cursor/rules/li-agent-scope-studio-sim.mdc"),
    ("../../.cursor/rules/li-studio-demo-native-only.mdc", f"{GITHUB}/.cursor/rules/li-studio-demo-native-only.mdc"),
    ("../../packages/li-studio/README.md", f"{GITHUB}/packages/li-studio/README.md"),
    ("../../../.cursor/rules/li-native-li-only.mdc", f"{GITHUB}/.cursor/rules/li-native-li-only.mdc"),
    ("../../.cursor/rules/li-world-studio-vision.mdc", f"{GITHUB}/.cursor/rules/li-world-studio-vision.mdc"),
    ("../../../../LAPTOP-SSH-SETUP.md", f"{GITHUB}/LAPTOP-SSH-SETUP.md"),
    ("../../../../scripts/README-devbox.md", f"{GITHUB}/scripts/README-devbox.md"),
    ("../../.cursor/rules/li-easy-imports.mdc", f"{GITHUB}/.cursor/rules/li-easy-imports.mdc"),
    (
        "../../packages/li-physics-core/docs/scalar-precision.md",
        f"{GITHUB}/packages/li-physics-core/docs/scalar-precision.md",
    ),
    ("./2026-05-25-md-r2-neighbor-list-gap.md", "../2026-05-25-md-r2-neighbor-list-gap.md"),
    ("docs/release-notes/2026-05-25-bench-fill-wp3-pde-robo-am.md", "../../release-notes/2026-05-25-bench-fill-wp3-pde-robo-am.md"),
    ("docs/release-notes/2026-05-28-bench-mean-std-timing.md", "../../release-notes/2026-05-28-bench-mean-std-timing.md"),
    ("STATUS.md", f"{GITHUB}/docs/reports/sim-plan/STATUS.md"),
    (
        "../../../../li-cursor-agents/config/goal-scaffolds/chem_sim_algorithms.md",
        "https://github.com/li-langverse/li-cursor-agents/blob/main/config/goal-scaffolds/chem_sim_algorithms.md",
    ),
    (
        "../../../.cursor/plans/li_execution_decorators_7c6e3b42.plan.md",
        f"{GITHUB}/.cursor/plans/li_execution_decorators_7c6e3b42.plan.md",
    ),
    (
        "../../../.cursor/skills/create-li-package/SKILL.md",
        "https://github.com/li-langverse/li-cursor-agents/blob/main/.cursor/skills/create-li-package/SKILL.md",
    ),
    (
        "../../../.cursor/rules/li-benchmark-correctness.mdc",
        f"{GITHUB}/.cursor/rules/li-benchmark-correctness.mdc",
    ),
]

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
]

LINK_RE = re.compile(r"(\[[^\]]*\]\()([^)]+)(\))")


def rewrite_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text
    rel = path.relative_to(DOCS)
    if rel.parts[:2] == ("superpowers", "plans"):
        for old, new in PLANS_SUBS:
            text = text.replace(old, new)
    for old, new in GLOBAL_SUBS:
        text = text.replace(old, new)

    def fix_link(match: re.Match[str]) -> str:
        prefix, target, suffix = match.group(1), match.group(2), match.group(3)
        if target.startswith(("http://", "https://", "mailto:", "#")):
            return match.group(0)
        if not target.endswith(".md") and ".md#" not in target and ".md)" not in target:
            if ".md" not in target.split("#")[0]:
                return match.group(0)
        # docs/foo/bar.md from anywhere -> relative from current file
        if target.startswith("docs/"):
            target_path = DOCS / target[5:]
            try:
                new_target = Path(
                    Path(*([".."] * (len(rel.parent.parts)))).joinpath(
                        *target_path.relative_to(DOCS).parts
                    )
                ).as_posix()
                return f"{prefix}{new_target}{suffix}"
            except ValueError:
                pass
        return match.group(0)

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
