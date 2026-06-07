#!/usr/bin/env python3
"""Write minimal safetensors/GGUF weight files for PH-ML Wave 13 T7 gates."""
import json
import os
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUT = ROOT / "packages" / "li-llm" / "fixtures" / "ph-ml-weights"
ROOT_FIXTURE = ROOT / "fixtures" / "ph-ml-weights"


def write_safetensors(path: Path) -> None:
    header = {
        "weight1": {"dtype": "F32", "shape": [2, 2], "data_offsets": [0, 16]},
        "weight2": {"dtype": "F32", "shape": [2, 2], "data_offsets": [16, 32]},
    }
    header_bytes = json.dumps(header, separators=(",", ":")).encode("utf-8")
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as fh:
        fh.write(struct.pack("<Q", len(header_bytes)))
        fh.write(header_bytes)
        fh.write(bytes(range(32)))


def write_gguf(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as fh:
        fh.write(b"GGUF")
        fh.write(struct.pack("<I", 3))
        fh.write(struct.pack("<Q", 2))
        fh.write(struct.pack("<Q", 0))


def main() -> int:
    out = Path(os.environ.get("PH_ML_WEIGHTS_FIXTURE", DEFAULT_OUT))
    write_safetensors(out / "model.safetensors")
    write_gguf(out / "model.gguf")
    if out != ROOT_FIXTURE:
        write_safetensors(ROOT_FIXTURE / "model.safetensors")
        write_gguf(ROOT_FIXTURE / "model.gguf")
    print(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
