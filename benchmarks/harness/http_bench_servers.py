"""Start/stop tier5_http servers (nginx, li-httpd) — shared by bench_http and verify_http."""

from __future__ import annotations

import os
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

from http_bench_toml import (
    REPO,
    TIER5,
    ensure_fixtures,
    merge_scenario,
    render_nginx_conf,
    resolve_document_root,
    scenario_backend_port,
    write_scenario_httpd_toml,
)

NGINX_CANDIDATES = (
    str(TIER5 / ".nginx-prefix" / "sbin" / "nginx"),
    "nginx",
    "/usr/sbin/nginx",
    "/usr/local/sbin/nginx",
)


def resolve_nginx_binary() -> str | None:
    for cand in NGINX_CANDIDATES:
        if Path(cand).is_file() and os.access(cand, os.X_OK):
            return cand
    found = shutil.which("nginx")
    return found if found else None


def scenario_port(cfg: dict[str, Any], name: str) -> int:
    """Stable listen port per scenario (not Python hash())."""
    global_tbl = cfg.get("global") or {}
    port_base = int(global_tbl.get("port_base", 18080))
    offset = sum(ord(c) for c in name) % 200
    return port_base + offset


def pick_free_port(base: int, offset: int, *, attempts: int = 40) -> int:
    for i in range(attempts):
        port = base + ((offset + i * 17) % 400)
        if port < 1024 or port > 65000:
            continue
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind(("127.0.0.1", port))
                return port
        except OSError:
            continue
    return base + (offset % 200)


def wait_port(port: int, timeout: float = 10.0) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                return True
        except OSError:
            time.sleep(0.05)
    return False


def stop_proc(proc: subprocess.Popen[object] | None) -> None:
    if proc is None:
        return
    proc.terminate()
    try:
        proc.wait(timeout=3)
    except subprocess.TimeoutExpired:
        proc.kill()


def nginx_error_text(prefix: Path, stderr: str) -> str:
    err = stderr.strip()
    elog = prefix / "logs" / "error.log"
    if elog.is_file():
        tail = elog.read_text(encoding="utf-8", errors="replace").strip()[-800:]
        if tail:
            err = f"{err}\n{tail}" if err else tail
    return err or "unknown nginx error"


def start_nginx(cfg: dict[str, Any], port: int) -> tuple[subprocess.Popen[object] | None, Path | None]:
    nginx = resolve_nginx_binary()
    if not nginx:
        return None, None
    conf_dir = Path(tempfile.mkdtemp(prefix="tier5_bench_"))
    conf_path = conf_dir / "nginx.conf"
    prefix = conf_dir / "prefix"
    conf_path.write_text(render_nginx_conf(cfg, port=port), encoding="utf-8")
    prefix.mkdir(parents=True, exist_ok=True)
    (prefix / "logs").mkdir(exist_ok=True)
    proc = subprocess.Popen(
        [nginx, "-g", "daemon off;", "-c", str(conf_path), "-p", str(prefix)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    time.sleep(0.35)
    if not wait_port(port, timeout=5.0):
        err = proc.stderr.read() if proc.stderr else ""
        stop_proc(proc)
        shutil.rmtree(conf_dir, ignore_errors=True)
        raise RuntimeError(f"nginx failed to start: {nginx_error_text(prefix, err)}")
    if proc.poll() is not None:
        err = proc.stderr.read() if proc.stderr else ""
        shutil.rmtree(conf_dir, ignore_errors=True)
        raise RuntimeError(f"nginx exited early: {nginx_error_text(prefix, err)}")
    return proc, conf_dir


def nextjs_toy_script() -> Path:
    return TIER5 / "fixtures" / "nextjs-toy" / "server.mjs"


def streaming_soak_script() -> Path:
    return TIER5 / "fixtures" / "streaming-soak" / "server.py"


def resolve_node_binary() -> str | None:
    return shutil.which("node") or shutil.which("nodejs")


def proxy_backend_available(cfg: dict[str, Any]) -> bool:
    server = cfg.get("server") or {}
    backend = server.get("backend")
    if backend == "nextjs_toy":
        return bool(resolve_node_binary() and nextjs_toy_script().is_file())
    if backend == "streaming_soak":
        return streaming_soak_script().is_file()
    return True


def start_nextjs_toy_backend(cfg: dict[str, Any], name: str) -> tuple[subprocess.Popen[object] | None, int]:
    server = cfg.get("server") or {}
    if server.get("backend") != "nextjs_toy":
        return None, scenario_backend_port(cfg, name)
    node = resolve_node_binary()
    script = nextjs_toy_script()
    backend_port = scenario_backend_port(cfg, name)
    if not node or not script.is_file():
        return None, backend_port
    proc = subprocess.Popen(
        [node, str(script), str(backend_port)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    if not wait_port(backend_port, timeout=8.0):
        err = proc.stderr.read() if proc.stderr else ""
        stop_proc(proc)
        raise RuntimeError(f"nextjs-toy failed on {backend_port}: {err.strip() or 'no listen'}")
    if proc.poll() is not None:
        err = proc.stderr.read() if proc.stderr else ""
        raise RuntimeError(f"nextjs-toy exited: {err.strip() or 'unknown'}")
    return proc, backend_port


def start_streaming_soak_backend(cfg: dict[str, Any], name: str) -> tuple[subprocess.Popen[object] | None, int]:
    server = cfg.get("server") or {}
    if server.get("backend") != "streaming_soak":
        return None, scenario_backend_port(cfg, name)
    script = streaming_soak_script()
    backend_port = scenario_backend_port(cfg, name)
    if not script.is_file():
        return None, backend_port
    load = cfg.get("load") or {}
    ws_frames = int(load.get("messages_min", 3)) if str(load.get("kind", "")) == "ws" else 3
    proc = subprocess.Popen(
        [sys.executable, str(script), str(backend_port), "--ws-frames", str(ws_frames)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    if not wait_port(backend_port, timeout=10.0):
        err = proc.stderr.read() if proc.stderr else ""
        stop_proc(proc)
        raise RuntimeError(f"streaming-soak failed on {backend_port}: {err.strip() or 'no listen'}")
    if proc.poll() is not None:
        err = proc.stderr.read() if proc.stderr else ""
        raise RuntimeError(f"streaming-soak exited: {err.strip() or 'unknown'}")
    return proc, backend_port


def start_proxy_backend(cfg: dict[str, Any], name: str) -> tuple[subprocess.Popen[object] | None, int]:
    server = cfg.get("server") or {}
    backend = server.get("backend")
    if backend == "streaming_soak":
        return start_streaming_soak_backend(cfg, name)
    return start_nextjs_toy_backend(cfg, name)


def prepare_li_httpd_conf(name: str, port: int, *, cfg: dict[str, Any] | None = None) -> tuple[Path, Path]:
    merged = cfg if cfg is not None else merge_scenario(name, profile="ci", overrides=None)
    ensure_fixtures(merged)
    work = Path(tempfile.mkdtemp(prefix="tier5_bench_li_"))
    server = merged.get("server") or {}
    if server.get("kind") == "proxy":
        backend_port = scenario_backend_port(merged, name)
        toml_path = work / "httpd.toml"
        write_scenario_httpd_toml(merged, front_port=port, backend_port=backend_port, out_path=toml_path)
        conf = work / "runtime.conf"
        flatten = REPO / "scripts" / "flatten-httpd-config.py"
        proc = subprocess.run(
            [sys.executable, str(flatten), str(toml_path), "-o", str(conf)],
            cwd=REPO,
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            shutil.rmtree(work, ignore_errors=True)
            raise RuntimeError(f"flatten-httpd-config failed: {proc.stderr.strip() or proc.stdout}")
        return conf, work
    doc_root = resolve_document_root(merged)
    conf = work / "runtime.conf"
    conf.write_text(f"listen_port={port}\ndocument_root={doc_root}\n", encoding="utf-8")
    return conf, work


def start_li_httpd(
    name: str,
    port: int,
    *,
    cfg: dict[str, Any] | None = None,
) -> tuple[subprocess.Popen[object] | None, Path | None]:
    bin_path = os.environ.get("LI_HTTPD_BIN", str(REPO / "build" / "li-httpd"))
    if not os.path.isfile(bin_path) or not os.access(bin_path, os.X_OK):
        return None, None
    conf_path, work_dir = prepare_li_httpd_conf(name, port, cfg=cfg)
    env = os.environ.copy()
    env.setdefault("LI_HTTPD_ACCESS_LOG", "0")
    proc = subprocess.Popen(
        [bin_path, str(conf_path)],
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    time.sleep(0.45)
    if proc.poll() is not None:
        err = proc.stderr.read() if proc.stderr else ""
        shutil.rmtree(work_dir, ignore_errors=True)
        raise RuntimeError(f"li-httpd failed to start: {err.strip() or 'unknown'}")
    if not wait_port(port, timeout=8.0):
        stop_proc(proc)
        shutil.rmtree(work_dir, ignore_errors=True)
        raise RuntimeError(f"li-httpd did not listen on {port}")
    return proc, work_dir


def bench_scenario_dir(name: str) -> Path:
    return TIER5 / "scenarios" / name


def is_proxy_scenario(cfg: dict[str, Any]) -> bool:
    server = cfg.get("server") or {}
    return server.get("kind") == "proxy"


def start_proxy_front(
    cfg: dict[str, Any],
    name: str,
    port: int,
    lang: str,
) -> tuple[subprocess.Popen[object] | None, Path | None, subprocess.Popen[object] | None]:
    """Start proxy backend (nextjs-toy or streaming-soak) and nginx or li-httpd front."""
    backend_proc: subprocess.Popen[object] | None = None
    if is_proxy_scenario(cfg):
        backend_proc, _ = start_proxy_backend(cfg, name)
    if lang == "nginx":
        front_proc, work_dir = start_nginx(cfg, port)
    elif lang == "li":
        front_proc, work_dir = start_li_httpd(name, port, cfg=cfg)
    else:
        raise RuntimeError(f"unsupported proxy front lang {lang!r}")
    return front_proc, work_dir, backend_proc


def stop_proxy_stack(
    front_proc: subprocess.Popen[object] | None,
    work_dir: Path | None,
    backend_proc: subprocess.Popen[object] | None,
) -> None:
    stop_proc(front_proc)
    stop_proc(backend_proc)
    if work_dir and work_dir.exists():
        shutil.rmtree(work_dir, ignore_errors=True)
