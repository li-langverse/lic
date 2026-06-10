#!/usr/bin/env bash
# Release fixed test ports used by li-httpd curl smokes (no blanket pkill).
set -euo pipefail

kill_port() {
  local port="$1"
  if command -v fuser >/dev/null 2>&1; then
    fuser -k "${port}/tcp" 2>/dev/null || true
    return 0
  fi
  python3 - "$port" <<'PY'
import os
import signal
import sys

port = int(sys.argv[1])
hex_port = f"{port:04X}"
seen = set()
for pid_s in os.listdir("/proc"):
    if not pid_s.isdigit():
        continue
    pid = int(pid_s)
    if pid == os.getpid():
        continue
    try:
        for line in open(f"/proc/{pid}/net/tcp", "r", encoding="utf-8"):
            parts = line.split()
            if len(parts) < 4 or parts[3] != "0A":
                continue
            local = parts[1]
            if local.endswith(f":{hex_port}"):
                seen.add(pid)
                break
    except OSError:
        continue
for pid in seen:
    try:
        os.kill(pid, signal.SIGKILL)
    except OSError:
        pass
PY
}

for port in "$@"; do
  kill_port "$port"
done

sleep 0.2
