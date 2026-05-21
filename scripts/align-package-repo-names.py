#!/usr/bin/env python3
"""Align monorepo package folders and metadata with import-based GitHub repo names.

  python3 scripts/align-package-repo-names.py --dry-run
  python3 scripts/align-package-repo-names.py --apply

Renames packages/<legacy>/ → packages/<li-physics-relativity>/ etc.,
updates packages/li.toml members and path dependencies.
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"
WORKSPACE = PACKAGES / "li.toml"

sys.path.insert(0, str(ROOT / "scripts"))
from import_repo_names import (  # noqa: E402
    canonical_folder_name,
    folder_import_map,
    import_name_to_github_repo,
    patch_package_toml,
    patch_publish_md,
)


def replace_path_deps(text: str, renames: dict[str, str]) -> str:
    for old, new in sorted(renames.items(), key=lambda x: -len(x[0])):
        text = text.replace(f'../{old}"', f'../{new}"')
        text = text.replace(f'../{old}/', f'../{new}/')
        text = text.replace(f'path = "../{old}"', f'path = "../{new}"')
    return text


def update_workspace_members(members: list[str], renames: dict[str, str]) -> list[str]:
    out = []
    for m in members:
        out.append(renames.get(m, m))
    return sorted(set(out))


def parse_members(text: str) -> list[str]:
    m = re.search(r"members\s*=\s*\[(.*?)\]", text, re.DOTALL)
    if not m:
        return []
    inner = m.group(1)
    return [x.strip().strip('"') for x in inner.split(",") if x.strip().strip('"')]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--dry-run", action="store_true", default=True)
    parser.add_argument("--metadata-only", action="store_true", help="only patch li.toml metadata")
    args = parser.parse_args()
    if args.apply:
        args.dry_run = False

    fmap = folder_import_map()
    renames: dict[str, str] = {}
    for folder in sorted(fmap.keys()):
        target = canonical_folder_name(folder)
        if folder != target and (PACKAGES / folder).is_dir():
            renames[folder] = target

    if not renames and not args.metadata_only:
        print("align-package-repo-names: folders already aligned")
    else:
        for old, new in sorted(renames.items()):
            imp = fmap[old]
            print(f"  {old} -> {new}  (import {imp}, github {import_name_to_github_repo(imp)})")

    for folder, imp in sorted(fmap.items()):
        pkg = PACKAGES / folder
        if not pkg.is_dir():
            pkg = PACKAGES / renames.get(folder, folder)
        if not pkg.is_dir():
            continue
        toml = pkg / "li.toml"
        pub = pkg / "PUBLISH.md"
        if toml.is_file():
            if args.dry_run:
                print(f"  would patch metadata: {toml.relative_to(ROOT)}")
            elif patch_package_toml(toml, imp):
                print(f"  patched metadata: {toml.relative_to(ROOT)}")
        if pub.is_file() and not args.dry_run:
            if patch_publish_md(pub, imp):
                print(f"  patched PUBLISH: {pub.relative_to(ROOT)}")

    if args.metadata_only:
        return 0

    if not renames:
        return 0

    if args.dry_run:
        print("align-package-repo-names: re-run with --apply to rename directories")
        return 0

    for old, new in renames.items():
        src = PACKAGES / old
        dst = PACKAGES / new
        if dst.exists():
            print(f"skip rename {old}: {new} exists", file=sys.stderr)
            continue
        print(f"rename {old} -> {new}")
        shutil.move(str(src), str(dst))
        toml = dst / "li.toml"
        if toml.is_file():
            text = toml.read_text(encoding="utf-8")
            text = re.sub(rf'^name\s*=\s*"{re.escape(old)}"', f'name = "{new}"', text, flags=re.M)
            text = re.sub(
                rf"PKG-{re.escape(old)}",
                f"PKG-{new}",
                text,
            )
            text = replace_path_deps(text, renames)
            toml.write_text(text, encoding="utf-8")
            patch_package_toml(toml, fmap[old])

    for pkg_dir in PACKAGES.iterdir():
        if not pkg_dir.is_dir():
            continue
        toml = pkg_dir / "li.toml"
        if not toml.is_file():
            continue
        text = toml.read_text(encoding="utf-8")
        new_text = replace_path_deps(text, renames)
        if new_text != text:
            toml.write_text(new_text, encoding="utf-8")
            print(f"  updated deps: {toml.relative_to(ROOT)}")

    if WORKSPACE.is_file():
        text = WORKSPACE.read_text(encoding="utf-8")
        members = parse_members(text)
        new_members = update_workspace_members(members, renames)
        new_inner = ", ".join(f'"{m}"' for m in new_members)
        new_text = re.sub(r"members\s*=\s*\[.*?\]", f"members = [{new_inner}]", text, count=1, flags=re.DOTALL)
        WORKSPACE.write_text(new_text, encoding="utf-8")
        print(f"updated {WORKSPACE.relative_to(ROOT)}")

    if renames and args.apply:
        replace_repo_paths(ROOT, renames)

    return 0


SKIP_REPLACE_DIRS = {".git", "build", "node_modules", "studio-demo-pkg"}


def replace_repo_paths(root: Path, renames: dict[str, str]) -> None:
    """Rewrite packages/<old>/ paths across the repo after directory renames."""
    exts = {
        ".md", ".mdc", ".toml", ".li", ".sh", ".yml", ".yaml", ".json",
        ".py", ".rs", ".c", ".h", ".txt",
    }
    for old, new in sorted(renames.items(), key=lambda x: -len(x[0])):
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if any(s in path.parts for s in SKIP_REPLACE_DIRS):
                continue
            if path.suffix not in exts and path.name not in ("AGENTS.md", "CHANGELOG.md"):
                continue
            try:
                text = path.read_text(encoding="utf-8")
            except (UnicodeDecodeError, OSError):
                continue
            needle = f"packages/{old}"
            if needle not in text:
                continue
            text = text.replace(needle, f"packages/{new}")
            text = text.replace(f"packages/{old}/", f"packages/{new}/")
            path.write_text(text, encoding="utf-8")
            print(f"  paths: {path.relative_to(root)}")


if __name__ == "__main__":
    raise SystemExit(main())
