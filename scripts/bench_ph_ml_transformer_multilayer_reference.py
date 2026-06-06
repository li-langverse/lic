#!/usr/bin/env python3
"""Reference multi-layer transformer top_id — mirrors li-llm ml_matmul_f32 matmul blocks."""
from __future__ import annotations

import json
import os
import struct
import time
from pathlib import Path


def scale_byte(b: int) -> float:
    return float(b) * 0.00390625


def float_bucket(v: float) -> int:
    bucket = 0
    if v >= 0.25:
        bucket = 1
    if v >= 0.75:
        bucket = 2
    if v >= 1.25:
        bucket = 3
    if v >= 2.0:
        bucket = 4
    return bucket


def load_safetensors_data(path: Path) -> tuple[bytes, int, int]:
    raw = path.read_bytes()
    header_len = struct.unpack("<Q", raw[:8])[0]
    data_offset = 8 + header_len
    return raw, data_offset, 16


def matmul_block_contrib(raw: bytes, data_offset: int, byte_len: int, tensor_index: int, tid: int) -> int:
    if tensor_index < 0 or tensor_index >= 4:
        return 0
    base = data_offset + tensor_index * byte_len
    if base + 4 > len(raw):
        return 0
    b = [scale_byte(raw[base + i]) for i in range(4)]
    a0 = scale_byte(tid)
    a1 = 1.0
    c0 = a0 * b[0] + a1 * b[2]
    c1 = a0 * b[1] + a1 * b[3]
    return float_bucket(c0) + float_bucket(c1) * 4


def reference_top_id(
    weights_path: Path,
    token_ids: list[int],
    *,
    seq_len: int = 0,
    num_layers: int = 2,
    vocab_size: int = 256,
) -> int:
    raw, data_offset, byte_len = load_safetensors_data(weights_path)
    layers = max(1, min(4, num_layers))
    score = seq_len
    for tid in token_ids:
        for layer in range(layers):
            score += matmul_block_contrib(raw, data_offset, byte_len, layer, tid)
    return score % vocab_size if vocab_size > 0 else 0


def main() -> int:
    root = Path(os.environ.get("PH_ML_STAGE9_ROOT", "."))
    out = Path(
        os.environ.get(
            "PH_ML_TRANSFORMER_MULTILAYER_OUT",
            root / "benchmarks/results/ph-ml-transformer-multilayer-parity.json",
        )
    )
    weights = root / "fixtures/ph-ml-weights/model.safetensors"
    report = {
        "suite": "ph-ml-transformer-multilayer-parity",
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "workload_class": "tier3_cpu",
        "num_layers": 2,
        "token_ids": [97, 98],
        "prompt": "ab",
        "reference_top_id": None,
        "li_top_id": None,
        "hf_top_id": None,
        "executed": False,
        "validity_gate_pass": False,
        "hf_executed": False,
        "note": None,
    }

    if not weights.is_file():
        report["note"] = "fixture weights missing"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(out)
        return 0

    ref_top = reference_top_id(weights, report["token_ids"])
    report["reference_top_id"] = ref_top

    li_top_raw = os.environ.get("PH_ML_LI_MULTILAYER_TOP_ID", "").strip()
    li_top = int(li_top_raw) if li_top_raw.isdigit() else None
    report["li_top_id"] = li_top

    parity_ok = li_top is not None and li_top == ref_top
    report["executed"] = li_top is not None
    report["validity_gate_pass"] = parity_ok

    try:
        import torch
        from transformers import GPT2Config, GPT2LMHeadModel

        cfg = GPT2Config(
            vocab_size=256,
            n_positions=64,
            n_embd=64,
            n_layer=2,
            n_head=4,
        )
        model = GPT2LMHeadModel(cfg)
        model.eval()
        with torch.no_grad():
            ids = torch.tensor([report["token_ids"]], dtype=torch.long)
            logits = model(ids).logits
            hf_top = int(logits[0, -1].argmax().item())
        report["hf_top_id"] = hf_top
        report["hf_executed"] = True
        report["note"] = (
            "Li reference matmul parity"
            + (" PASS" if parity_ok else " FAIL")
            + "; HF tiny-GPT2 shape smoke (not weight parity)"
        )
    except ImportError:
        report["note"] = (
            "Li reference matmul parity"
            + (" PASS" if parity_ok else (" pending Li smoke" if li_top is None else " FAIL"))
            + "; transformers/torch not installed for HF smoke"
        )
    except Exception as exc:  # noqa: BLE001
        report["note"] = (
            f"reference ok={ref_top}; HF smoke skipped: {str(exc)[:120]}"
        )

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
