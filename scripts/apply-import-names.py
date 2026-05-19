#!/usr/bin/env python3
"""Set package.metadata.li import_name for ergonomic imports (physics.relativity, math, ui)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"

# Official package folder -> import path (see docs/language/import-style.md)
IMPORT_NAMES: dict[str, str] = {
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


def patch_toml(path: Path, import_name: str) -> bool:
    text = path.read_text(encoding="utf-8")
    line = f'import_name = "{import_name}"'
    if "import_name" in text:
        text = re.sub(r'import_name\s*=\s*"[^"]*"', line, text)
    elif "[package.metadata.li]" in text:
        text = text.replace(
            "[package.metadata.li]\n",
            f"[package.metadata.li]\n{line}\n",
        )
    else:
        text += f"\n[package.metadata.li]\n{line}\n"
    if text != path.read_text(encoding="utf-8"):
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> int:
    changed = 0
    for folder, name in sorted(IMPORT_NAMES.items()):
        toml = PACKAGES / folder / "li.toml"
        if not toml.is_file():
            continue
        if patch_toml(toml, name):
            print(f"  {folder} -> {name}")
            changed += 1
    print(f"apply-import-names: updated {changed} packages")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
