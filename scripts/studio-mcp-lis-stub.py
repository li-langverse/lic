#!/usr/bin/env python3
"""MCP stdio JSON-RPC stub for lis mcp li-engine (PH-AGENT-1)."""
import json
import subprocess
import sys

DISPATCH = sys.argv[1] if len(sys.argv) > 1 else ""
TOOLS = [
    {
        "name": "world_scaffold",
        "description": "world scaffold (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"template_id": {"type": "string"}, "target_dir": {"type": "string"}},
            "required": ["template_id", "target_dir"],
            "additionalProperties": False,
        },
    },
    {
        "name": "sim_set_profile",
        "description": "sim profile (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"profile": {"type": "string"}},
            "required": ["profile"],
            "additionalProperties": False,
        },
    },
    {
        "name": "lic_check",
        "description": "lic check (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"paths": {"type": "array", "items": {"type": "string"}}},
            "additionalProperties": False,
        },
    },
    {
        "name": "lic_build",
        "description": "lic build proof gate (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"target": {"type": "string"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "publish_bundle",
        "description": "publish bundle (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"out_path": {"type": "string"}},
            "required": ["out_path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "am_export_print",
        "description": "additive export (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"job_path": {"type": "string"}, "printer_id": {"type": "string"}},
            "required": ["job_path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "chem_dft_run",
        "description": "chem dft (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"input_path": {"type": "string"}, "method": {"type": "string"}},
            "required": ["input_path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "studio_adaptive_layout",
        "description": "adaptive layout (stub)",
        "inputSchema": {
            "type": "object",
            "properties": {"role": {"type": "string"}, "stage": {"type": "string"}},
            "required": ["role", "stage"],
            "additionalProperties": False,
        },
    },
]
SERVER_INFO = {"name": "li-studio-engine", "version": "0.1.0-stub"}


def write(msg: dict) -> None:
    sys.stdout.write(json.dumps(msg, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def run_dispatch(tool_name: str) -> tuple[str, bool]:
    proc = subprocess.run([DISPATCH, tool_name], capture_output=True, text=True, check=False)
    body = (proc.stdout or "").strip()
    return body, proc.returncode == 0


def main() -> None:
    for raw in sys.stdin:
        line = raw.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError:
            continue
        req_id = req.get("id")
        method = req.get("method", "")
        params = req.get("params") or {}
        if method == "notifications/initialized" or req_id is None:
            continue
        if method == "initialize":
            write(
                {
                    "jsonrpc": "2.0",
                    "id": req_id,
                    "result": {
                        "protocolVersion": "2024-11-05",
                        "capabilities": {"tools": {}},
                        "serverInfo": SERVER_INFO,
                    },
                }
            )
            continue
        if method == "tools/list":
            write({"jsonrpc": "2.0", "id": req_id, "result": {"tools": TOOLS}})
            continue
        if method == "tools/call":
            name = str(params.get("name", ""))
            body, ok = run_dispatch(name)
            payload = body if body else json.dumps({"error": "dispatch_failed", "tool": name})
            write(
                {
                    "jsonrpc": "2.0",
                    "id": req_id,
                    "result": {
                        "content": [{"type": "text", "text": payload}],
                        "isError": not ok,
                    },
                }
            )
            continue
        write(
            {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"method not found: {method}"},
            }
        )


if __name__ == "__main__":
    main()
