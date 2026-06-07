#!/usr/bin/env python3
"""lis mcp li-engine — stdio MCP server for World Studio (WP-AG-03).

Transport bridge for Cursor MCP clients. Tool names and arg slots match
packages/li-studio studio_mcp_* registry and li_rt_studio_mcp_tool_match_name.
"""
from __future__ import annotations

import json
import sys
from typing import Any

SERVER_NAME = "li-engine"
SERVER_VERSION = "0.1.0"
PROTOCOL_VERSION = "2024-11-05"

# Stable MCP tool table — keep in sync with docs/game-dev/studio-mcp-tools.md
TOOLS: list[dict[str, Any]] = [
    {
        "name": "world_scaffold",
        "description": "Create world.li + assets/ + studio.toml from template",
        "inputSchema": {
            "type": "object",
            "properties": {"profile": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "sim_set_profile",
        "description": "Set [engine] profile in studio.toml",
        "inputSchema": {
            "type": "object",
            "properties": {"profile": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "lic_check",
        "description": "Run lic check --format=json; return diagnostics",
        "inputSchema": {
            "type": "object",
            "properties": {"pass_gate": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "lic_build",
        "description": "Run lic build; required before publish/export",
        "inputSchema": {
            "type": "object",
            "properties": {"pass_gate": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "publish_bundle",
        "description": "Write repro bundle after proof pass",
        "inputSchema": {
            "type": "object",
            "properties": {"export_mask": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "am_export_print",
        "description": "Export slice/mesh to printer pipeline",
        "inputSchema": {
            "type": "object",
            "properties": {"format": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "chem_dft_run",
        "description": "Queue QM/DFT job via li-chem",
        "inputSchema": {
            "type": "object",
            "properties": {"method": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "studio_adaptive_layout",
        "description": "Drug/role adaptive shell layout",
        "inputSchema": {
            "type": "object",
            "properties": {"stage": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "studio_set_viewport_background",
        "description": "Set viewport background preset (0 solid, 1 grid, 2 gradient)",
        "inputSchema": {
            "type": "object",
            "properties": {"bg": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "studio_set_particle_display",
        "description": "MD particle tier label (-1 off, 0-2 = 1k/10k/100k)",
        "inputSchema": {
            "type": "object",
            "properties": {"tier_id": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "studio_set_biomol_style",
        "description": "Biomolecule representation (0 cartoon, 1 surface, 2 sticks)",
        "inputSchema": {
            "type": "object",
            "properties": {"style": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_session_start",
        "description": "Start persistent headless Studio UI session (Playwright browser context)",
        "inputSchema": {
            "type": "object",
            "properties": {
                "profile": {"type": "string"},
                "size": {"type": "array", "items": {"type": "integer"}},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_session_stop",
        "description": "Stop UI session",
        "inputSchema": {
            "type": "object",
            "properties": {"session_id": {"type": "string"}},
            "required": ["session_id"],
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_snapshot",
        "description": "Accessibility-style element tree for session",
        "inputSchema": {
            "type": "object",
            "properties": {"session_id": {"type": "string"}},
            "required": ["session_id"],
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_click",
        "description": "Click element by stable dot-path id",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {"type": "string"},
                "element_id": {"type": "string"},
            },
            "required": ["session_id", "element_id"],
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_key",
        "description": "Send key action (cmd_k, escape, digit_1, ...)",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {"type": "string"},
                "key": {"type": "string"},
            },
            "required": ["session_id", "key"],
            "additionalProperties": False,
        },
    },
    {
        "name": "ui_wait",
        "description": "Wait ms or frames in session",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {"type": "string"},
                "ms": {"type": "integer"},
                "frames": {"type": "integer"},
            },
            "required": ["session_id"],
            "additionalProperties": False,
        },
    },
    {
        "name": "demo_record_start",
        "description": "Start demo recording from script_path",
        "inputSchema": {
            "type": "object",
            "properties": {"script_path": {"type": "string"}},
            "required": ["script_path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "demo_record_finish",
        "description": "Finish recording → MP4 + trace",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {"type": "string"},
                "out_mp4": {"type": "string"},
            },
            "required": ["session_id", "out_mp4"],
            "additionalProperties": False,
        },
    },
]

TOOL_INDEX = {t["name"]: i for i, t in enumerate(TOOLS)}

_UI_SESSIONS: dict[str, dict[str, Any]] = {}
_UI_SESSION_SEQ = 0

# Dispatch arg slots mirror studio_mcp_tool_dispatch_arg int normalization (stub path).
STATUS_OK = 2
STATUS_FAILED = 3
RESULT_OK = 0
RESULT_ERR_PROOF = 1
RESULT_ERR_IO = 2


def _int_arg(args: dict[str, Any], *keys: str, default: int = 0) -> int:
    for key in keys:
        if key in args and isinstance(args[key], int):
            return args[key]
    return default


def _next_session_id() -> str:
    global _UI_SESSION_SEQ
    _UI_SESSION_SEQ += 1
    return f"ui-{ _UI_SESSION_SEQ }"


def _ui_snapshot_stub(session: dict[str, Any]) -> dict[str, Any]:
    return {
        "session_id": session["session_id"],
        "element_count": 20,
        "profile": session.get("profile", "game"),
        "elements": [
            {"id": "shell.dock.slot.0", "role": "button"},
            {"id": "shell.dock.slot.1", "role": "button"},
            {"id": "shell.palette.row.0", "role": "button"},
            {"id": "shell.agent.send_button", "role": "button"},
        ],
        "palette_open": session.get("palette_open", 0),
        "dock_slot": session.get("dock_slot", 0),
    }


def dispatch_tool(name: str, arguments: dict[str, Any]) -> dict[str, Any]:
    """In-process stub dispatch — matches studio_mcp_tool_dispatch_arg semantics."""
    if name not in TOOL_INDEX:
        return {
            "ok": False,
            "status": STATUS_FAILED,
            "result_code": RESULT_ERR_IO,
            "tool_id": 0,
        }

    if name == "ui_session_start":
        sid = _next_session_id()
        _UI_SESSIONS[sid] = {
            "session_id": sid,
            "profile": arguments.get("profile", "game"),
            "dock_slot": 0,
            "palette_open": 0,
            "frame_clock": 0,
        }
        snap = _ui_snapshot_stub(_UI_SESSIONS[sid])
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 20, "session_id": sid, "snapshot": snap}

    if name == "ui_session_stop":
        sid = str(arguments.get("session_id", ""))
        _UI_SESSIONS.pop(sid, None)
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 21}

    if name == "ui_snapshot":
        sid = str(arguments.get("session_id", ""))
        session = _UI_SESSIONS.get(sid)
        if session is None:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_IO, "tool_id": 12}
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 12, "snapshot": _ui_snapshot_stub(session)}

    if name == "ui_click":
        sid = str(arguments.get("session_id", ""))
        session = _UI_SESSIONS.get(sid)
        if session is None:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_IO, "tool_id": 13}
        eid = str(arguments.get("element_id", ""))
        if "dock.slot.1" in eid:
            session["dock_slot"] = 1
        if "palette.row.0" in eid:
            session["palette_open"] = 1
        session["frame_clock"] = int(session.get("frame_clock", 0)) + 1
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 13, "snapshot": _ui_snapshot_stub(session)}

    if name == "ui_key":
        sid = str(arguments.get("session_id", ""))
        session = _UI_SESSIONS.get(sid)
        if session is None:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_IO, "tool_id": 14}
        key = str(arguments.get("key", ""))
        if key == "cmd_k":
            session["palette_open"] = 1
        session["frame_clock"] = int(session.get("frame_clock", 0)) + 1
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 14, "snapshot": _ui_snapshot_stub(session)}

    if name == "ui_wait":
        sid = str(arguments.get("session_id", ""))
        if sid not in _UI_SESSIONS:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_IO, "tool_id": 16}
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 16}

    if name == "demo_record_start":
        sid = _next_session_id()
        script_path = str(arguments.get("script_path", ""))
        _UI_SESSIONS[sid] = {"session_id": sid, "record": True, "script_path": script_path, "trace_lines": []}
        return {"ok": True, "status": STATUS_OK, "result_code": RESULT_OK, "tool_id": 17, "session_id": sid, "trace_path": "build/demo-recorder/run/demo_trace.jsonl"}

    if name == "demo_record_finish":
        sid = str(arguments.get("session_id", ""))
        out_mp4 = str(arguments.get("out_mp4", "build/demo-recorder/out/demo.mp4"))
        if sid not in _UI_SESSIONS:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_IO, "tool_id": 19}
        return {
            "ok": True,
            "status": STATUS_OK,
            "result_code": RESULT_OK,
            "tool_id": 19,
            "mp4": out_mp4,
            "trace": "build/demo-recorder/run/demo_trace.jsonl",
            "provenance": "build/demo-recorder/run/capture-provenance.json",
            "duration_s": 10.0,
            "note": "Run studio-demo-replay.sh for native MP4 bytes; MCP returns session metadata.",
        }

    tool_id = TOOL_INDEX[name] + 1
    arg = 0

    if name == "lic_check":
        arg = _int_arg(arguments, "pass_gate", default=0)
        if arg < 0:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_PROOF, "tool_id": tool_id}
    elif name == "lic_build":
        arg = _int_arg(arguments, "pass_gate", default=0)
        if arg == -1:
            return {"ok": False, "status": STATUS_FAILED, "result_code": RESULT_ERR_PROOF, "tool_id": tool_id}
    elif name in ("world_scaffold", "sim_set_profile"):
        arg = _int_arg(arguments, "profile", default=0)
    elif name == "publish_bundle":
        arg = _int_arg(arguments, "export_mask", default=4)  # 3mf mask stub
    elif name == "am_export_print":
        arg = _int_arg(arguments, "format", default=0)
    elif name == "chem_dft_run":
        arg = _int_arg(arguments, "method", default=0)
    elif name == "studio_adaptive_layout":
        arg = _int_arg(arguments, "stage", default=0)
    elif name == "studio_set_viewport_background":
        arg = max(0, min(2, _int_arg(arguments, "bg", default=0)))
    elif name == "studio_set_particle_display":
        arg = max(-1, min(2, _int_arg(arguments, "tier_id", default=0)))
    elif name == "studio_set_biomol_style":
        arg = max(0, min(2, _int_arg(arguments, "style", default=0)))

    return {"ok": True, "status": STATUS_OK, "result_code": arg, "tool_id": tool_id}


def write_message(payload: dict[str, Any]) -> None:
    body = json.dumps(payload, separators=(",", ":"))
    sys.stdout.write(f"Content-Length: {len(body.encode('utf-8'))}\r\n\r\n{body}")
    sys.stdout.flush()


def handle_request(req: dict[str, Any]) -> None:
    method = req.get("method")
    req_id = req.get("id")

    if method == "initialize":
        write_message(
            {
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "protocolVersion": PROTOCOL_VERSION,
                    "capabilities": {"tools": {}},
                    "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
                },
            }
        )
        return

    if method == "notifications/initialized":
        return

    if method == "ping":
        write_message({"jsonrpc": "2.0", "id": req_id, "result": {}})
        return

    if method == "tools/list":
        write_message({"jsonrpc": "2.0", "id": req_id, "result": {"tools": TOOLS}})
        return

    if method == "tools/call":
        params = req.get("params") or {}
        name = params.get("name", "")
        arguments = params.get("arguments") or {}
        if not isinstance(arguments, dict):
            arguments = {}
        outcome = dispatch_tool(name, arguments)
        if not outcome["ok"]:
            write_message(
                {
                    "jsonrpc": "2.0",
                    "id": req_id,
                    "result": {
                        "content": [
                            {
                                "type": "text",
                                "text": json.dumps(outcome),
                            }
                        ],
                        "isError": True,
                    },
                }
            )
            return
        write_message(
            {
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [{"type": "text", "text": json.dumps(outcome)}],
                    "isError": False,
                },
            }
        )
        return

    if req_id is not None:
        write_message(
            {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Method not found: {method}"},
            }
        )


def read_message() -> dict[str, Any] | None:
    headers: dict[str, str] = {}
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            return None
        decoded = line.decode("utf-8", errors="replace").strip()
        if decoded == "":
            break
        if ":" in decoded:
            key, value = decoded.split(":", 1)
            headers[key.strip().lower()] = value.strip()
    length = int(headers.get("content-length", "0"))
    if length <= 0:
        return None
    body = sys.stdin.buffer.read(length)
    return json.loads(body.decode("utf-8"))


def main() -> int:
    while True:
        msg = read_message()
        if msg is None:
            break
        handle_request(msg)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
