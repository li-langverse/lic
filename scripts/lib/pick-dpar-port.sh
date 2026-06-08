#!/usr/bin/env bash
# Pick a free localhost TCP port for li_dpar multi-rank smokes (avoids 29600-series collisions).
pick_dpar_port() {
  if [[ -n "${LI_DPAR_PORT:-}" ]]; then
    echo "$LI_DPAR_PORT"
    return 0
  fi
  python3 - <<'PY'
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
}
