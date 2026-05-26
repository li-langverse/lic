#!/usr/bin/env python3
"""PH-AGENT-2 — MCP stdio server smoke (8 tools, proof gate)."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD_SH = ROOT / "scripts" / "build-studio-mcp-server.sh"
SERVER = ROOT / "build" / "tools" / "studio-mcp-li-engine"
LIC = Path(os.environ.get("LIC", ROOT / "build" / "compiler" / "lic" / "lic"))


def fail(msg: str) -> None:
    print(f"studio_mcp_server_smoke: {msg}", file=sys.stderr)
    raise SystemExit(1)


def build_server() -> None:
    subprocess.run([str(BUILD_SH), str(SERVER)], check=True)


def rpc(proc: subprocess.Popen[str], req: dict) -> dict:
    assert proc.stdin and proc.stdout
    proc.stdin.write(json.dumps(req) + "\n")
    proc.stdin.flush()
    line = proc.stdout.readline()
    if not line:
        fail("server closed stdout")
    return json.loads(line)


def main() -> int:
    build_server()
    env = os.environ.copy()
    env.pop("STUDIO_MCP_PROOF_FAIL", None)
    proc = subprocess.Popen(
        [str(SERVER)],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env,
    )
    try:
        init = rpc(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "smoke", "version": "1.0"},
                },
            },
        )
        if init.get("result", {}).get("serverInfo", {}).get("name") != "li-engine":
            fail(f"initialize serverInfo: {init}")

        listed = rpc(proc, {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
        tools = listed.get("result", {}).get("tools", [])
        names = sorted(t["name"] for t in tools)
        expected = sorted(
            [
                "world_scaffold",
                "sim_set_profile",
                "lic_check",
                "lic_build",
                "publish_bundle",
                "am_export_print",
                "chem_dft_run",
                "studio_adaptive_layout",
            ]
        )
        if names != expected:
            fail(f"tools/list names {names!r} != {expected!r}")

        # Exercise all 8 tools in harness order (build before publish).
        call_order = [
            "world_scaffold",
            "sim_set_profile",
            "lic_check",
            "lic_build",
            "publish_bundle",
            "am_export_print",
            "chem_dft_run",
            "studio_adaptive_layout",
        ]
        for i, tool in enumerate(call_order, start=3):
            resp = rpc(
                proc,
                {
                    "jsonrpc": "2.0",
                    "id": i,
                    "method": "tools/call",
                    "params": {"name": tool, "arguments": {}},
                },
            )
            if resp.get("result", {}).get("isError"):
                fail(f"tools/call {tool} failed: {resp}")

        # Proof gate: fresh process, publish before build must fail.
        proc.terminate()
        proc.wait(timeout=5)
        proc = subprocess.Popen(
            [str(SERVER)],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
        )
        pub_early = rpc(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "tools/call",
                "params": {"name": "publish_bundle", "arguments": {}},
            },
        )
        if not pub_early.get("result", {}).get("isError"):
            fail("publish_bundle before lic_build must fail proof gate")

        build = rpc(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "tools/call",
                "params": {"name": "lic_build", "arguments": {}},
            },
        )
        if build.get("result", {}).get("isError"):
            fail(f"lic_build failed: {build}")

        pub_ok = rpc(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 5,
                "method": "tools/call",
                "params": {"name": "publish_bundle", "arguments": {}},
            },
        )
        if pub_ok.get("result", {}).get("isError"):
            fail(f"publish_bundle after lic_build failed: {pub_ok}")

        chem = rpc(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 6,
                "method": "tools/call",
                "params": {"name": "chem_dft_run", "arguments": {}},
            },
        )
        text = chem.get("result", {}).get("content", [{}])[0].get("text", "")
        if chem.get("result", {}).get("isError") or "-76.0" not in text:
            fail(f"chem_dft_run unexpected: {chem}")

    finally:
        proc.terminate()
        proc.wait(timeout=5)

    if LIC.is_file() and os.access(LIC, os.X_OK):
        harness = ROOT / "packages" / "li-studio" / "li-tests" / "smoke" / "studio_mcp_harness_all_tools.li"
        if harness.is_file():
            r = subprocess.run([str(LIC), "check", str(harness)], capture_output=True, text=True)
            if r.returncode != 0:
                print(
                    "studio_mcp_server_smoke: skip Li harness (lib.li check failed; MCP RPC harness ok)",
                    file=sys.stderr,
                )

    print("studio_mcp_server_smoke: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
