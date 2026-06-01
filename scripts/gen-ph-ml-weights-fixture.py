#!/usr/bin/env python3
"""Create minimal safetensors/GGUF fixture files for PH-ML Wave 13 T7 gates."""
from __future__ import annotations

import json
import os
import struct
import sys
from pathlib import Path


def write_safetensors(path: Path) -> None:
    header = json.dumps({"tensor_a": {"dtype": "F32", "shape": [2, 2], "data_offsets": [0, 16]}})
    payload = header.encode("utf-8")
    path.write_bytes(struct.pack("<Q", len(payload)) + payload + b"\x00" * 16)


def write_gguf(path: Path) -> None:
    path.write_bytes(b"GGUF" + struct.pack("<I", 3) + b"\x00" * 32)


def main() -> int:
    root = Path(os.environ.get("PH_ML_WEIGHTS_FIXTURE", "benchmarks/fixtures/ph-ml-weights"))
    root.mkdir(parents=True, exist_ok=True)
    write_safetensors(root / "model.safetensors")
    write_gguf(root / "model.gguf")
    meta = {"generated": True, "files": ["model.safetensors", "model.gguf"]}
    (root / "fixture.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(root)
    return 0


if __name__ == "__main__":
    sys.exit(main())
