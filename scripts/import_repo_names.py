#!/usr/bin/env python3
"""Map import paths to official GitHub repo names (same string as import).

Convention: `import studio` → repo `studio`; `import studio.ai` → repo `studio.ai`.
Monorepo folder under packages/ should match the import path.

See docs/ecosystem/package-import-naming.md
"""
from __future__ import annotations

import re
from pathlib import Path

PACKAGES = Path(__file__).resolve().parents[1] / "packages"

# Legacy monorepo folder → import (pre-rename)
LEGACY_FOLDER_IMPORT: dict[str, str] = {
    "li-std-math": "math",
    "li-std-numerics": "math.numerics",
    "li-std-core": "core",
    "li-std-ui": "ui",
    "li-std-scene": "scene",
    "li-std-physics-core": "physics.core",
    "li-std-physics-rigid": "physics.rigid",
    "li-std-physics-runtime": "physics.runtime",
    "li-std-physics-particles": "physics.particles",
    "li-std-physics-fluids": "physics.fluids",
    "li-std-physics-weather": "physics.weather",
    "li-std-physics-aero": "physics.aero",
    "li-std-physics-chem": "physics.chem",
    "li-std-physics-em": "physics.em",
    "li-std-physics-quantum": "physics.quantum",
    "li-std-physics-relativity": "physics.relativity",
    "li-std-physics-hep": "physics.hep",
    "li-httpd": "net.httpd",
    "li-net": "net",
    "li-demo": "demo",
}


def import_name_to_github_repo(import_name: str) -> str:
    """Repo slug = import path (dots allowed on GitHub)."""
    name = import_name.strip()
    if not name:
        raise ValueError("empty import_name")
    return name


def pkg_id_for_import(import_name: str) -> str:
    """PKG-studio, PKG-studio-ai (dots → hyphen in id only)."""
    slug = import_name.replace(".", "-")
    return f"PKG-{slug}"


def folder_import_map() -> dict[str, str]:
    """Every packages/<folder>/ with li.toml → import_name."""
    m = dict(LEGACY_FOLDER_IMPORT)
    for toml in sorted(PACKAGES.glob("*/li.toml")):
        folder = toml.parent.name
        text = toml.read_text(encoding="utf-8")
        imp = read_toml_field(text, "import_name")
        if imp:
            m[folder] = imp
        elif folder.startswith("li-"):
            # Heuristic: li-foo-bar → foo.bar (legacy folders without metadata)
            rest = folder[3:].replace("-", ".")
            if rest:
                m.setdefault(folder, rest)
    return m


def canonical_folder_name(folder: str) -> str:
    """Target packages/<name>/ directory (= import path)."""
    m = folder_import_map()
    if folder in m:
        return import_name_to_github_repo(m[folder])
    return folder


def read_toml_field(text: str, key: str) -> str | None:
    m = re.search(rf'^{re.escape(key)}\s*=\s*"([^"]*)"', text, re.MULTILINE)
    return m.group(1) if m else None


def patch_package_toml(path: Path, import_name: str) -> bool:
    text = path.read_text(encoding="utf-8")
    github_repo = import_name_to_github_repo(import_name)
    pkg_id = pkg_id_for_import(import_name)
    orig = text

    def upsert(key: str, value: str) -> None:
        nonlocal text
        line = f'{key} = "{value}"'
        if re.search(rf"^{re.escape(key)}\s*=", text, re.MULTILINE):
            text = re.sub(rf'^{re.escape(key)}\s*=\s*"[^"]*"', line, text, flags=re.MULTILINE)
        elif "[package.metadata.li]" in text:
            text = text.replace(
                "[package.metadata.li]\n",
                f"[package.metadata.li]\n{line}\n",
            )
        else:
            text += f"\n[package.metadata.li]\n{line}\n"

    text = re.sub(r'^name\s*=\s*"[^"]*"', f'name = "{import_name}"', text, count=1, flags=re.M)
    upsert("import_name", import_name)
    upsert("github_repo", github_repo)
    upsert("pkg_id", pkg_id)

    text = re.sub(
        r'^url\s*=\s*"https://github\.com/li-langverse/[^"]*"',
        f'url = "https://github.com/li-langverse/{github_repo}"',
        text,
        flags=re.MULTILINE,
    )
    text = re.sub(
        r"https://li-langverse\.github\.io/li-language/ecosystem/[^/\"]+/",
        f"https://li-langverse.github.io/li-language/ecosystem/{github_repo}/",
        text,
    )
    text = re.sub(
        r"https://github\.com/li-langverse/[^/]+/blob/main/",
        f"https://github.com/li-langverse/{github_repo}/blob/main/",
        text,
    )

    if text != orig:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def patch_publish_md(path: Path, import_name: str) -> bool:
    if not path.is_file():
        return False
    github_repo = import_name_to_github_repo(import_name)
    pkg_id = pkg_id_for_import(import_name)
    text = path.read_text(encoding="utf-8")
    orig = text
    text = re.sub(r"\*\*PKG id\*\* \| `[^`]*`", f"**PKG id** | `{pkg_id}`", text, count=1)
    text = re.sub(
        r"\*\*Registry name\*\* \| `[^`]+`",
        f"**Registry name** | `{import_name}`",
        text,
        count=1,
    )
    text = re.sub(
        r"https://github\.com/li-langverse/[^\s|]+",
        f"https://github.com/li-langverse/{github_repo}",
        text,
    )
    if text != orig:
        path.write_text(text, encoding="utf-8")
        return True
    return False


if __name__ == "__main__":
    for folder in sorted(p.name for p in PACKAGES.iterdir() if p.is_dir()):
        imp = folder_import_map().get(folder)
        if not imp:
            continue
        target = canonical_folder_name(folder)
        repo = import_name_to_github_repo(imp)
        print(f"{folder:28} → {target:22} import={imp:20} github={repo}")
