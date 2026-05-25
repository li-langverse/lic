"""Builtin tier5 HTTP attack drivers (OWASP/CWE class probes)."""

from __future__ import annotations

from typing import Any

import http_attacks
import http_weaponized

ALL_DRIVERS = {**http_attacks.DRIVERS, **http_weaponized.WEAPONIZED_DRIVERS}


def _stub_outcome(cfg: dict[str, Any], *, lang: str) -> dict[str, Any]:
    expect = cfg.get("expect") or {}
    if not isinstance(expect, dict):
        return {"no_crash": True, "legitimate_client_ok": True}
    stricter = expect.get("li_behavior") == "stricter"
    out: dict[str, Any] = {"no_crash": True}
    for key, want in expect.items():
        if key == "li_behavior":
            continue
        if want is None:
            continue
        if stricter and key == "reject_or_close_attack":
            out[key] = lang == "li"
            continue
        if isinstance(want, bool):
            out[key] = want
        else:
            out[key] = want
    if stricter:
        out["li_stricter"] = lang == "li"
    return out


def run(cfg: dict[str, Any], *, lang: str, stub: bool, port: int) -> dict[str, Any]:
    attack = cfg.get("attack") or {}
    if not isinstance(attack, dict):
        attack = {}
    builtin = str(attack.get("builtin") or cfg.get("id", ""))
    if stub:
        return _stub_outcome(cfg, lang=lang)
    fn = ALL_DRIVERS.get(builtin)
    if fn is None:
        raise KeyError(f"unknown builtin attack {builtin!r}")
    return fn("127.0.0.1", port, attack)
